//
//  EndPoint.swift
//  Gil
//
//  Created by Antonio Banda  on 09/05/25.
//

import Foundation

enum EndPoint {
    
    static let baseURL = "https://app.fipros.com/api"
    
    case profileUser
    case newUser
    case updateUserName
    case logUser
    case forgotPassword
    case updatePassword
    case newContact
    case updateContact
    case getContacts
    case getFriends
    case newFriend
    case solFriend
    
    var url : URL {
        
        switch self {
        case .profileUser:
            return URL(string: "\(EndPoint.baseURL)/users/updateProfile")!
        case .newUser:
            return URL(string: "\(EndPoint.baseURL)/users/newUser")!
        case .updateUserName:
            return URL(string: "\(EndPoint.baseURL)/users/updateName")!
        case .logUser:
            return URL(string: "\(EndPoint.baseURL)/users/login")!
        case .forgotPassword:
            return URL(string: "\(EndPoint.baseURL)/users/forgotPass")!
        case .updatePassword:
            return URL(string: "\(EndPoint.baseURL)/users/updatePass")!
        case .newContact:
            return URL(string: "\(EndPoint.baseURL)/contacts/newContacts")!
        case.updateContact:
            return URL(string: "\(EndPoint.baseURL)/contacts/updateContact")!
        case.getContacts:
            return URL(string: "\(EndPoint.baseURL)/contacts/contacts")!
        case.getFriends:
            return URL(string: "\(EndPoint.baseURL)/friends/friends")!
        case.newFriend:
            return URL(string: "\(EndPoint.baseURL)/friends/newFriend")!
        case.solFriend:
            return URL(string: "\(EndPoint.baseURL)/friends/solFriend")!
        }
        
    }
        
}
