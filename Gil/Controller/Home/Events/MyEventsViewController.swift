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
    
    let eventsLabel: UILabel = {
        let label = UILabel()
        label.text = "no_events_found".localized()
        label.textAlignment = .center
        label.textColor = .gray
        label.font = Constants.Fonts.fontBold
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tvEvents.dataSource = self
        tvEvents.delegate = self
        
        
        tvEvents.isSkeletonable = true
        
        self.tvEvents.showAnimatedGradientSkeleton(usingGradient: skeletonColor, animation: fastShimmer, transition: .none)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.initUI()
        }
        
        self.observeConnectionChanges { [weak self] isConnected in
                self?.initUI()
        }
        
        
        NotificationCenter.default.addObserver(self, selector:#selector(initUI), name: NSNotification.Name("ADD_EVENT"), object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(initUI), name: NSNotification.Name("UPDATE_CONTACT"), object:nil)
       
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.eventsLabel.isHidden = true
        /*DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.initUI()
        }*/
    }
    
    @objc func initUI(){
        self.eventsLabel.isHidden = true
        self.tvEvents.showAnimatedGradientSkeleton(usingGradient: skeletonColor, animation: fastShimmer, transition: .none)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if(self.isConnected){
                self.pendingEventsApi{ pending in
                    self.updateEventsApi {
                        self.getEvents()
                    }
                }
            }else{
                self.getEvents()
                Utils.Snackbar.snackbarWithAction(message: "no_internet_connection".localized(), bgColor: Constants.Colors.red!, titleAction: "close".localized() , duration: 5.0)
            }
        }
        
        view.addSubview(eventsLabel)

        NSLayoutConstraint.activate([
            eventsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            eventsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    
    @objc
    func updateEventsApi(completion: @escaping () -> Void) {
        let userId = UserDefaults.standard.integer(forKey: "userId")
        
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
                   // print("Eventos Actualizados")
                    case .failure(let error):
                    print("Error al actualizar eventos desde el api : \(error)")
                }
                completion()
            }
            
        }
       
    }
    
    @objc
    func pendingEventsApi(completion: @escaping (Bool) -> Void){
        eventPendingApi = DataManager.shared.getEventsPending()
        if(!eventPendingApi.isEmpty){
            let group = DispatchGroup()
            
            for eventEntity in eventPendingApi {
                group.enter()
                
                print(eventEntity.eventImg ?? "NoURL")
                let myEventDto = EventDto(entity: eventEntity)
                
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
                                    
                                self.serviceManager.updateEvent(image: self.eventImage, fileName: "eventImage.jpg", event: myEventDto) { result in
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
                            
                        self.serviceManager.updateEvent(image: self.eventImage, fileName: "eventImage.jpg", event: myEventDto) { result in
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
                completion(true)
            }
            
        }else{
            completion(false)
            
        }
    }
    
    
    //MARK: Events
    
    func getEvents(){
        DispatchQueue.main.async{
            self.events = DataManager.shared.getAllEvents()
            
            self.tvEvents.reloadData()
            self.tvEvents.stopSkeletonAnimation()
            self.tvEvents.hideSkeleton()
            
            if(self.events.count > 0){
                self.eventsLabel.isHidden = true
            }else{
                self.eventsLabel.isHidden = false
            }
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
    
    var eventSelected : EventEntity?

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        eventSelected = events[indexPath.row]
        performSegue(withIdentifier: "eventDetailSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "eventDetailSegue" {
            if let eventDestino = segue.destination as? EditEventViewController {
                eventDestino.eventRecived = eventSelected
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellEvent", for: indexPath) as! EventTableViewCell
        
        
        let event = events[indexPath.row]
       
            let currentLocale = Locale.current
            let fromFormat = "yyyy-MM-dd HH:mm"
            var toFormat = ""
            
            if(currentLocale.identifier == "en_MX"){
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
