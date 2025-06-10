//
//  EndPoint.swift
//  Gil
//
//  Created by Antonio Banda  on 09/05/25.
//

import Foundation

enum EndPoint {
    
    static let baseURL = "https://app.fipros.com/api"
    
    case newUser
    case logUser
    case forgotPassword
    case updatePassword
    
    var url : URL {
        
        switch self {
        case .newUser:
            return URL(string: "\(EndPoint.baseURL)/users/newUser")!
        case .logUser:
            return URL(string: "\(EndPoint.baseURL)/users/login")!
        case .forgotPassword:
            return URL(string: "\(EndPoint.baseURL)/users/forgotPass")!
        case .updatePassword:
            return URL(string: "\(EndPoint.baseURL)/users/updatePass")!
        }
        
    }
        
}
