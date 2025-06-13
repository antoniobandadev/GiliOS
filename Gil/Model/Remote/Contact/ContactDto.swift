//
//  ContactDto.swift
//  Gil
//
//  Created by Antonio Banda  on 12/06/25.
//


struct ContactDto : Codable {
    
    let contactId: String?
    let userId: Int?
    let contactName: String?
    let contactEmail: String?
    let contactStatus: String?
    let contactType: String?
    
    init(contactId: String?, userId: Int?, contactName: String?, contactEmail: String?, contactStatus: String?, contactType: String?){
        
        self.contactId = contactId
        self.userId = userId
        self.contactName = contactName
        self.contactEmail = contactEmail
        self.contactStatus = contactStatus
        self.contactType = contactType
    
    }
    
}

extension ContactDto {
    init(entity: ContactEntity) {
        self.contactId = entity.contactId
        self.userId = Int(entity.userId)
        self.contactName = entity.contactName
        self.contactEmail = entity.contactEmail
        self.contactStatus = entity.contactStatus
        self.contactType = entity.contactType
    }
}


extension Array where Element == ContactEntity {
    func toDTOs() -> [ContactDto] {
        return self.map { ContactDto(entity: $0) }
    }
}

//let recoveredDTO = ContactDto(entity: contact)
