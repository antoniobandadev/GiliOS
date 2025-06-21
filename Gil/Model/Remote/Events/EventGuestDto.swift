//
//  EventGuestDto.swift
//  Gil
//
//  Created by Antonio Banda  on 21/06/25.
//

struct EventGuestDto : Codable {
    
    var eventId: Int?
    var eventName: String?
    var eventDesc: String?
    var eventType: String?
    var eventDateStart: String?
    var eventDateEnd: String?
    var eventStreet: String?
    var eventCity: String?
    var guestInvName: String?
    var guestsQR: String?
    
    init(eventId: Int?,
         eventName: String?,
         eventDesc: String?,
         eventType: String?,
         eventDateStart: String?,
         eventDateEnd: String?,
         eventStreet: String?,
         eventCity: String?,
         guestInvName: String?,
         guestsQR: String? ){
        
            self.eventId = eventId
            self.eventName = eventName
            self.eventDesc = eventDesc
            self.eventType = eventType
            self.eventDateStart = eventDateStart
            self.eventDateEnd = eventDateEnd
            self.eventStreet = eventStreet
            self.eventCity = eventCity
            self.guestInvName = guestInvName
            self.guestsQR = guestsQR
    
    }
    
}

