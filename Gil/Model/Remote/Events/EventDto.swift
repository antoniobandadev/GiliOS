//
//  EventDto.swift
//  Gil
//
//  Created by Antonio Banda  on 15/06/25.
//

struct EventDto : Codable {
    
    var eventId: Int?
    var eventName: String?
    var eventDesc: String?
    var eventType: String?
    var eventDateStart: String?
    var eventDateEnd: String?
    var eventStreet: String?
    var eventCity: String?
    var eventStatus: String?
    var eventImg: String?
    var eventCreatedAt: String?
    var userId: Int?
    var eventSync: Int?
    var userIdScan: Int?
    
    init(eventId: Int?,
         eventName: String?,
         eventDesc: String?,
         eventType: String?,
         eventDateStart: String?,
         eventDateEnd: String?,
         eventStreet: String?,
         eventCity: String?,
         eventStatus: String?,
         eventImg: String?,
         eventCreatedAt: String?,
         userId: Int?,
         eventSync: Int?,
         userIdScan: Int? ){
        
            self.eventId = eventId
            self.eventName = eventName
            self.eventDesc = eventDesc
            self.eventType = eventType
            self.eventDateStart = eventDateStart
            self.eventDateEnd = eventDateEnd
            self.eventStreet = eventStreet
            self.eventCity = eventCity
            self.eventStatus = eventStatus
            self.eventImg = eventImg
            self.eventCreatedAt = eventCreatedAt
            self.userId = userId
            self.eventSync = eventSync
            self.userIdScan = userIdScan
    
    }
    
}

extension EventDto {
    init(entity: EventEntity) {
        self.eventId = Int(entity.eventId)
        self.eventName = entity.eventName
        self.eventDesc = entity.eventDesc
        self.eventType = entity.eventType
        self.eventDateStart = entity.eventDateStart
        self.eventDateEnd = entity.eventDateEnd
        self.eventStreet = entity.eventStreet
        self.eventCity = entity.eventCity
        self.eventStatus = entity.eventStatus
        self.eventImg = entity.eventImg
        self.eventCreatedAt = entity.eventCreatedAt
        self.userId = Int(entity.userId)
        self.eventSync = Int(entity.eventSync)
        self.userIdScan = Int(entity.userIdScan)
    }
}


extension Array where Element == EventEntity {
    func toDTOs() -> [EventDto] {
        return self.map { EventDto(entity: $0) }
    }
}
