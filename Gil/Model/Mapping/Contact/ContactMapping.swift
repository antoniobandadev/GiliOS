//
//  ContactMapping.swift
//  Gil
//
//  Created by Antonio Banda  on 12/06/25.
//

import Foundation
import CoreData

extension ContactEntity {
    func update(from dto: ContactDto) {
        self.contactId = dto.contactId
        self.userId = Int16(dto.userId!)
        self.contactName = dto.contactName
        self.contactEmail = dto.contactEmail
        self.contactStatus = dto.contactStatus
        self.contactType = dto.contactType
    }

    static func from(dto: ContactDto, context: NSManagedObjectContext) -> ContactEntity {
        let contact = ContactEntity(context: context)
        contact.update(from: dto)
        return contact
    }
}
