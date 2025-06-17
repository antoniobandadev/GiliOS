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
        
       
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func initUI(){
        if(isConnected){
            pendingEventsApi{
                self.updateEventsApi {
                    self.getEvents()
                }
            }
        }else{
            getEvents()
        }
    }
    
    
    @objc
    func updateEventsApi(completion: @escaping () -> Void) {
        let userId = UserDefaults.standard.integer(forKey: "userId")
        let currentLocale = Locale.current
        let fromFormat = "yyyy-MM-dd HH:mm"
        var toFormat = ""
        
        if(currentLocale.identifier == "es_MX"){
            toFormat = "dd/MM/yyyy" // HH:mm
        }else{
            toFormat = "MM/dd/yyyy" //HH:mm
        }
        
        DataManager.shared.deleteAllEvents(context: self.context)
        
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
                        eventsApi.eventDateStart = Utils.dateFormatString(date: eventDto.eventDateStart!, fromFormat: fromFormat, toFormat: toFormat)
                        eventsApi.eventDateEnd = Utils.dateFormatString(date: eventDto.eventDateEnd!, fromFormat: fromFormat, toFormat: toFormat)
                        eventsApi.eventStreet = eventDto.eventStreet
                        eventsApi.eventCity = eventDto.eventCity
                        eventsApi.eventStatus = eventDto.eventStatus
                        eventsApi.eventImg = eventDto.eventImg
                        eventsApi.userId = Int16(userId)
                        eventsApi.eventSync = Int16(eventDto.eventSync!)
                        eventsApi.userIdScan = Int16(eventDto.userIdScan!)
                        eventsApiArray.append(eventsApi)
                        }
                    
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
            for eventEntity in eventPendingApi {
                
                let _ = EventDto(entity: eventEntity)
                if let image = UIImage(contentsOfFile: eventEntity.eventImg!) {
                    eventImage = image
                } else {
                    eventImage = nil
                }
                
                if(eventEntity.eventId == 0){
                    
                    serviceManager.uploadEvent(image: eventImage, fileName: "eventImage.jpg", event: eventEntity){ result in
                        switch result {
                        case .success(_):
                            
                            eventEntity.eventSync = 1
                            
                            do {
                                try self.context.save()

                            } catch {
                                print("Error al guardar eventos pendientes: \(error)")
                            }
                            
                        case .failure(let error):
                            print("Error al enviar eventos pendientes: \(error)")
                        }
                    }
                    
                }else{
                        
                    serviceManager.updateEvent(image: eventImage, fileName: "eventImage.jpg", event: eventEntity) { result in
                        switch result {
                        case .success(_):
                            
                            eventEntity.eventSync = 1
                                
                            do {
                                try self.context.save()

                            } catch {
                                print("Error al guardar contactos pendientes: \(error)")
                            }
                            
                        case .failure(let error):
                            print("Error al enviar contactos pendientes: \(error)")
                        }
                    }
                }
            }
        }
        completion()
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
        let dateStart = event.eventDateStart ?? ""
        let dateEnd = event.eventDateEnd ?? ""
        
        cell.ivEventImage.image = nil
        cell.lbEventTitle.text = event.eventName
        cell.lbEventDesc.text = event.eventDesc
        cell.lbEventDate.text = dateStart + " - " + dateEnd
        
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
