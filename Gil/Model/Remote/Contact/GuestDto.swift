//
//  GuestDto.swift
//  Gil
//
//  Created by Antonio Banda  on 23/06/25.
//


struct GuestDto : Codable {
    
    let contactId: String?
    let contactName: String?
    let contactEmail: String?
    let contactStatus: String?
    let contactType: String?
    
    init(contactId: String?, contactName: String?, contactEmail: String?, contactStatus: String?, contactType: String?){
        
        self.contactId = contactId
        self.contactName = contactName
        self.contactEmail = contactEmail
        self.contactStatus = contactStatus
        self.contactType = contactType
    
    }
    
}
