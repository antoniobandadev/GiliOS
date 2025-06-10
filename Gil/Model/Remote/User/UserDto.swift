//
//  UserDto.swift
//  Gil
//
//  Created by Antonio Banda  on 09/05/25.
//

struct UserDto : Codable {
    
    let userId: Int?
    let userName: String?
    let userEmail: String?
    let userDeviceId: String?
    let userPassword: String?
    let userProfile: String?
    let userStatus: String?
    let userCreatedAt: String?
    
    init(userId: Int?, userName: String? ,userEmail: String?, userDeviceId: String? , userPassword: String?, userProfile: String?, userStatus: String?, userCreatedAt: String?){
        
        self.userId = userId
        self.userName = userName
        self.userEmail = userEmail
        self.userDeviceId = userDeviceId
        self.userPassword = userPassword
        self.userProfile = userProfile
        self.userStatus = userStatus
        self.userCreatedAt = userCreatedAt
        
    }
    
    
}
