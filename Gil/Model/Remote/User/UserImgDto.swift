//
//  UserImgDto.swift
//  Gil
//
//  Created by Antonio Banda  on 28/06/25.
//

struct UserImgDto : Codable {
    
    let userId: String?
    let userProfile: String?
    
    init(userId: String?, userProfile: String?){
        
        self.userId = userId
        self.userProfile = userProfile
        
    }
    
}
