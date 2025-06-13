//
//  FriendDto.swift
//  Gil
//
//  Created by Antonio Banda  on 12/06/25.
//

struct FriendDto : Codable {
    
    let contactId: Int?
    let userId: Int?
    let contactName: String?
    let contactEmail: String?
    let contactStatus: String?
    let contactType: String?
    
    init(contactId: Int?, userId: Int?, contactName: String?, contactEmail: String?, contactStatus: String?, contactType: String?){
        
        self.contactId = contactId
        self.userId = userId
        self.contactName = contactName
        self.contactEmail = contactEmail
        self.contactStatus = contactStatus
        self.contactType = contactType
    
    }
    
}

struct SolFriendDto : Codable {
    
    let userId: Int?
    let friendId: Int?
    let friendStatus: String?
    
    init(userId: Int?, friendId: Int? ,friendStatus: String?){
        
        self.userId = userId
        self.friendId = friendId
        self.friendStatus = friendStatus
        
    }
    
}

extension FriendDto {
    init(entity: ContactEntity) {
        self.contactId = Int(entity.contactId!)
        self.userId = Int(entity.userId)
        self.contactName = entity.contactName
        self.contactEmail = entity.contactEmail
        self.contactStatus = entity.contactStatus
        self.contactType = entity.contactType
    }
}


extension Array where Element == ContactEntity {
    func toDTOs() -> [FriendDto] {
        return self.map { FriendDto(entity: $0) }
    }
}
