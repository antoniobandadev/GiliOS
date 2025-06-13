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
    
    func insertContacts(_ contacts: [ContactEntity]){
        saveContext()
    }
    
    func getContactsPending() -> [ContactEntity] {
        var contactArray = [ContactEntity]()
        let contactQuery = ContactEntity.fetchRequest()
        let contactFilter = NSPredicate(format: "contactSinc = false")
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
    
    
}
