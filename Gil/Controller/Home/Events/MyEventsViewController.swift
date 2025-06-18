//
//  MyEventsViewController.swift
//  Gil
//
//  Created by Antonio Banda  on 01/05/25.
//

import UIKit
import SkeletonView
import Kingfisher

class MyEventsViewController: UIViewController, SkeletonTableViewDataSource, UITableViewDelegate , UITextFieldDelegate {
    
    let fastShimmer = SkeletonAnimationBuilder()
           .makeSlidingAnimation(withDirection: .leftRight, duration: 0.5)
    let skeletonColor = SkeletonGradient(baseColor: UIColor.darkGray)
    
    let serviceManager = ServiceManager.shared
    let context = DataManager.shared.persistentContainer.viewContext
    
    var eventPendingApi: [EventEntity] = []
    var events: [EventEntity] = []
    
    var eventImage : UIImage?

    @IBOutlet weak var tvEvents: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tvEvents.dataSource = self
        tvEvents.delegate = self
        
        
        tvEvents.isSkeletonable = true
        
        self.tvEvents.showAnimatedGradientSkeleton(usingGradient: skeletonColor, animation: fastShimmer, transition: .none)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.initUI()
        }
        
        NotificationCenter.default.addObserver(self, selector:#selector(initUI), name: NSNotification.Name("ADD_EVENT"), object:nil)
       
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @objc func initUI(){
        if(isConnected){
            pendingEventsApi{
                print("Eventos pendientes Listos")
                self.updateEventsApi {
                    print("Borrando y trayendo de nuevo")
                    self.getEvents()
                        print("Mostrando los eventos")
                }
            }
        }else{
            getEvents()
        }
    }
    
    
    @objc
    func updateEventsApi(completion: @escaping () -> Void) {
        let userId = UserDefaults.standard.integer(forKey: "userId")
        //let currentLocale = Locale.current
        //let fromFormat = "yyyy-MM-dd HH:mm"
        //var toFormat = ""
        
        /*if(currentLocale.identifier == "es_MX"){
            toFormat = "dd/MM/yyyy HH:mm" // HH:mm
        }else{
            toFormat = "MM/dd/yyyy HH:mm" //HH:mm
        }*/
        
        /*eventsApi.eventDateStart = Utils.dateFormatString(date: eventDto.eventDateStart!, fromFormat: fromFormat, toFormat: toFormat)
        eventsApi.eventDateEnd = Utils.dateFormatString(date: eventDto.eventDateEnd!, fromFormat: fromFormat, toFormat: toFormat)*/
        
        
        
        serviceManager.getEvents(userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let events):
                    var eventsApiArray: [EventEntity] = []
                    
                    for eventDto in events {
                        let eventsApi = EventEntity(context: self.context)
                        eventsApi.eventId = Int16(eventDto.eventId!)
                        eventsApi.eventName = eventDto.eventName
                        eventsApi.eventDesc = eventDto.eventDesc
                        eventsApi.eventType = eventDto.eventType
                        eventsApi.eventDateStart = eventDto.eventDateStart
                        eventsApi.eventDateEnd = eventDto.eventDateEnd
                        eventsApi.eventStreet = eventDto.eventStreet
                        eventsApi.eventCity = eventDto.eventCity
                        eventsApi.eventStatus = eventDto.eventStatus
                        eventsApi.eventImg = eventDto.eventImg
                        eventsApi.userId = Int16(userId)
                        eventsApi.eventSync = Int16(eventDto.eventSync!)
                        eventsApi.userIdScan = Int16(eventDto.userIdScan!)
                        eventsApiArray.append(eventsApi)
                        }
                        DataManager.shared.deleteAllEvents(context: self.context)
                        DataManager.shared.insertEvents(eventsApiArray)
                    print("Eventos Actualizados")
                    case .failure(let error):
                    print("Error al actualizar eventos desde el api : \(error)")
                }
                completion()
            }
            
        }
       
    }
    
    @objc
    func pendingEventsApi(completion: @escaping () -> Void) {
        eventPendingApi = DataManager.shared.getEventsPending()
        if(!eventPendingApi.isEmpty){
            let group = DispatchGroup()
            
            for eventEntity in eventPendingApi {
                group.enter()
                
                print(eventEntity.eventImg ?? "NoURL")
                let _ = EventDto(entity: eventEntity)
                
                 if let url = URL(string: eventEntity.eventImg ?? "") {
                    KingfisherManager.shared.retrieveImage(with: url) { result in
                        //print(result)
                        switch result {
                        case .success(let value):
                            self.eventImage = value.image
                            print("Imagen cargada desde: \(value.cacheType)") // memory, disk, none
                            // Puedes usar `image` como UIImage directamente
                            if(eventEntity.eventId == 0){
                                
                                self.serviceManager.uploadEvent(image: self.eventImage, fileName: "eventImage.jpg", event: eventEntity){ result in
                                    switch result {
                                    case .success(_):
                                        group.leave()
                                        
                                    case .failure(let error):
                                        print("Error al actualizar eventos pendientes: \(error)")
                                        group.leave()
                                    }
                                    
                                }
                                
                            }else{
                                    
                                self.serviceManager.updateEvent(image: self.eventImage, fileName: "eventImage.jpg", event: eventEntity) { result in
                                    switch result {
                                    case .success(_):
                                        group.leave()
                                        
                                    case .failure(let error):
                                        print("Error al actualizar eventos pendientes: \(error)")
                                        group.leave()
                                       
                                    }
                                   
                                }
                            }
                        case .failure(let error):
                            self.eventImage = nil
                            print("Error al obtener la imagen:", error)
                        }
                    }
                }else{
                    self.eventImage = nil
                    print("sin imagen")
                    if(eventEntity.eventId == 0){
                        
                        self.serviceManager.uploadEvent(image: self.eventImage, fileName: "eventImage.jpg", event: eventEntity){ result in
                            switch result {
                            case .success(_):
                                group.leave()
                                
                            case .failure(let error):
                                print("Error al actualizar eventos pendientes: \(error)")
                                group.leave()
                            }
                           
                        }
                        
                    }else{
                            
                        self.serviceManager.updateEvent(image: self.eventImage, fileName: "eventImage.jpg", event: eventEntity) { result in
                            switch result {
                            case .success(_):
                                group.leave()
                                
                            case .failure(let error):
                                print("Error al actualizar eventos pendientes: \(error)")
                                group.leave()
                            }
                           
                        }
                    }
                }//Tiene imagen
                
               
            }// For
            
            group.notify(queue: .main) {
                completion()
            }
        }else{
            completion()
        }
    }
    
    
    //MARK: Events
    
    func getEvents(){
        DispatchQueue.main.async{
            print("cargandoEventos")
            self.events = DataManager.shared.getAllEvents()
            print("pintandoEventos")
            self.tvEvents.reloadData()
            print("quitando skeleton")
            self.tvEvents.stopSkeletonAnimation()
            self.tvEvents.hideSkeleton()
        }
    }
    
    
    
    
    
    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
       // #warning Incomplete implementation, return the number of sections
       return 1
   }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // #warning Incomplete implementation, return the number of rows
        return events.count
        //return isLoading ? 5 : data.count
        // orka
        //
        
   }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       //performSegue(withIdentifier: menuOptions[indexPath.row].segue, sender: nil)
       //if let cell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell {
       // let contact = searchContacts[indexPath.row]
        //Utils.AlertCustomUtils.showEditCustomAlert(on: self, title: "update_contact".localized(), newContact:false, contact: contact)
           // cell.lbName.textColor = Constants.Colors.secondary
     //   }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellEvent", for: indexPath) as! EventTableViewCell
        
        
        let event = events[indexPath.row]
       
            let currentLocale = Locale.current
            let fromFormat = "yyyy-MM-dd HH:mm"
            var toFormat = ""
            
            if(currentLocale.identifier == "es_MX"){
                toFormat = "dd/MM/yyyy"
            }else{
                toFormat = "MM/dd/yyyy"
            }
            
            let dateStart = Utils.dateFormatString(date: event.eventDateStart ?? "", fromFormat: fromFormat, toFormat: toFormat)
            let dateEnd = Utils.dateFormatString(date: event.eventDateEnd ?? "", fromFormat: fromFormat, toFormat: toFormat)
            
            cell.ivEventImage.image = nil
            cell.lbEventTitle.text = event.eventName
            cell.lbEventDesc.text = event.eventDesc
            cell.lbEventDate.text = dateStart! + " - " + dateEnd!
            
           if let imageUrl = event.eventImg {
                
                let url = URL(string: imageUrl)
                let placeholder = UIImage(named: "ic_event_img")
                
                cell.ivEventImage.kf.setImage(
                    with: url,
                    placeholder: placeholder,
                    options: [
                        .transition(.fade(0.3)),
                        .cacheOriginalImage
                    ])
            } else {
                cell.ivEventImage.image = UIImage(named: "ic_event_img")
            }
        
       return cell
   }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? EventTableViewCell {
            UIView.animate(withDuration: 0.1) {
                cell.eventCardView.backgroundColor = Constants.Colors.gray
            }
        }
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? EventTableViewCell{
            UIView.animate(withDuration: 0.2) {
                cell.eventCardView.backgroundColor = Constants.Colors.primaryLigth
            }
        }
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "cellEvent"
    }

}
