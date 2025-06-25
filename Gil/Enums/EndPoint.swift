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
    case newEvent
    case updateEvent
    case getEvent
    case deleteEvent
    case getInvites
    case getGuests
    case getGuestsContacts
    case getGuestsFriends
    case getAllGuests
    case newGuest
    
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
        case.newEvent:
            return URL(string: "\(EndPoint.baseURL)/events/newEvent")!
        case.updateEvent:
            return URL(string: "\(EndPoint.baseURL)/events/updateEvent")!
        case.getEvent:
            return URL(string: "\(EndPoint.baseURL)/events/events")!
        case.deleteEvent:
            return URL(string: "\(EndPoint.baseURL)/events/deleteEvent")!
        case.getInvites:
            return URL(string: "\(EndPoint.baseURL)/events/myEvents")!
        case.getGuests:
            return URL(string: "\(EndPoint.baseURL)/guests/myGuestInvite")!
        case.getGuestsContacts:
            return URL(string: "\(EndPoint.baseURL)/contacts/guestContacts")!
        case.getGuestsFriends:
            return URL(string: "\(EndPoint.baseURL)/contacts/guestFriends")!
        case.getAllGuests:
            return URL(string: "\(EndPoint.baseURL)/guests/myGuestCF")!
        case.newGuest:
            return URL(string: "\(EndPoint.baseURL)/guests/newGuest")!
        }
        
    }
        
}
