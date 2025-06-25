//
//  InviteDto.swift
//  Gil
//
//  Created by Antonio Banda  on 24/06/25.
//

struct InviteDto : Codable {
    
    let eventId: Int?
    let guestInvName: String?
    let guestsType: Int?
    let contactId: String?
    let userId: Int?
    let userSendId: Int?
    let userLanguage: String?
    
    init(eventId: Int?, guestInvName: String?, guestsType: Int?, contactId: String?, userId: Int?, userSendId: Int?, userLanguage: String?){
        
        self.eventId = eventId
        self.guestInvName = guestInvName
        self.guestsType = guestsType
        self.contactId = contactId
        self.userId = userId
        self.userSendId = userSendId
        self.userLanguage = userLanguage
    
    }
    
}
