//
//  ForgotPassDto.swift
//  Gil
//
//  Created by Antonio Banda  on 09/06/25.
//

struct ForgotPassDto : Codable {
    
    let userPassId: Int?
    let userId: Int?
    let userPassCode: Int?
    
    init(userPassId: Int?, userId: Int? ,userPassCode: Int?){
        
        self.userPassId = userPassId
        self.userId = userId
        self.userPassCode = userPassCode
        
    }
    
    
}

struct UpdatePassDto : Codable {
    
    let userId: Int?
    let userPassword: String?
    
    init(userId: Int? ,userPassword: String?){
        
        self.userId = userId
        self.userPassword = userPassword
        
    }
    
}
