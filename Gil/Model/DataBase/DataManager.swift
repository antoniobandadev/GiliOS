//
//  DataManager.swift
//  Gil
//
//  Created by Antonio Banda  on 12/06/25.
//

import Foundation
import CoreData

class DataManager : NSObject {
    static let shared = DataManager()
    
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Gil")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Error al cargar Core Data: \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //MARK: Contacts
    
    func getContacts() -> [ContactEntity] {
        var contactArray = [ContactEntity]()
        let contactQuery = ContactEntity.fetchRequest()
        let contactFilter = NSPredicate(format: "contactStatus != 'C' AND contactType = 'C'")
        contactQuery.predicate = contactFilter
        
        do{
            contactArray = try persistentContainer.viewContext.fetch(contactQuery)
        }
        catch{
            print ("no se puede ejecutar el query SELECT * FROM Contacts")
        }
        let sortedArray = contactArray.sorted { m1, m2 in
            return m1.contactName ?? "" < m2.contactName ?? ""
        }
        return sortedArray
    }
    
    func getFriendsArray() -> [String: String] {
        let context = persistentContainer.viewContext
        let contactQuery = ContactEntity.fetchRequest()
        let contactFilter = NSPredicate(format: "contactStatus != 'C' AND contactType = 'F'")
        contactQuery.predicate = contactFilter

        do {
            let contacts = try context.fetch(contactQuery)
            let contactDict = contacts.reduce(into: [String: String]()) { dict, contact in
                if let name = contact.contactName {
                    dict[(contact.contactId!)] = name
                }
            }
            return contactDict
        } catch {
            print("Error al obtener amigos: \(error)")
            return [:]
        }
    }
    
    
    func insertContacts(_ contacts: [ContactEntity]){
        saveContext()
    }
    
    func getContactsPending() -> [ContactEntity] {
        var contactArray = [ContactEntity]()
        let contactQuery = ContactEntity.fetchRequest()
        let contactFilter = NSPredicate(format: "contactSync = 0")
        contactQuery.predicate = contactFilter
        
        do{
            contactArray = try persistentContainer.viewContext.fetch(contactQuery)
        }
        catch{
            print ("no se puede ejecutar el query SELECT * FROM Contacts pending")
        }
        let sortedArray = contactArray.sorted { m1, m2 in
            return m1.contactName ?? "" < m2.contactName ?? ""
        }
        return sortedArray
    }
    
    func deleteAllContacts(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ContactEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
            print("Todos los contactos han sido eliminados.")
        } catch {
            print("Error al eliminar contactos: \(error)")
        }
    }
    
    //MARK: Events
    
    func saveEventDB(event : EventEntity) -> Bool {
        let context = persistentContainer.viewContext
        
        do {
            if context.hasChanges {
                try context.save()
                print("Evento Guardado")
            }
            return true
           
        } catch {
            print("Error al guardar evento: \(error.localizedDescription)")
            return false
        }
    }
    
    func updateEventDB(eventUpdate: EventDto) -> Bool {
        let context = persistentContainer.viewContext

        let fetchRequest: NSFetchRequest<EventEntity> = EventEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "eventId == %d", eventUpdate.eventId!)

        do {
            let results = try context.fetch(fetchRequest)
            let event: EventEntity

            if let existingEvent = results.first {
                event = existingEvent
                
                event.eventName = eventUpdate.eventName
                event.eventDesc = eventUpdate.eventDesc
                event.eventType = eventUpdate.eventType
                event.eventDateStart = eventUpdate.eventDateStart
                event.eventDateEnd = eventUpdate.eventDateEnd
                event.eventStreet = eventUpdate.eventStreet
                event.eventCity = eventUpdate.eventCity
                event.eventStatus = eventUpdate.eventStatus
                event.eventImg = eventUpdate.eventImg
                event.eventSync = Int16(eventUpdate.eventSync!)
                event.userIdScan = Int16(eventUpdate.userIdScan!)
            }

            try context.save()
            print("Evento actualizado")
            return true

        } catch {
            print("Error al actualizar evento: \(error.localizedDescription)")
            return false
        }
    }
    
    func getEventsPending() -> [EventEntity] {
        var eventArray = [EventEntity]()
        let eventQuery = EventEntity.fetchRequest()
        let eventFilter = NSPredicate(format: "eventSync = 0")
        eventQuery.predicate = eventFilter
        
        do{
            eventArray = try persistentContainer.viewContext.fetch(eventQuery)
        }
        catch{
            print ("no se puede ejecutar el query SELECT * FROM Events pending")
        }
        
        return eventArray
    }
    
    func deleteAllEvents(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = EventEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
            print("Todos los eventos han sido eliminados.")
        } catch {
            print("Error al eliminar contactos: \(error)")
        }
    }
    
    func insertEvents(_ events: [EventEntity]){
        saveContext()
    }
    
    func getAllEvents() -> [EventEntity] {
        var eventArray = [EventEntity]()
        let eventQuery = EventEntity.fetchRequest()
        let eventFilter = NSPredicate(format: "eventStatus = 'A'")
        eventQuery.predicate = eventFilter
        
        do{
            eventArray = try persistentContainer.viewContext.fetch(eventQuery)
        }
        catch{
            print ("no se puede ejecutar el query SELECT * FROM Events pending")
        }
        
        
        let sortedArray = eventArray.sorted { m1, m2 in
            return m1.eventDateStart ?? "" > m2.eventDateStart ?? ""
        }
        
        return sortedArray
    }
    
    
    
}
