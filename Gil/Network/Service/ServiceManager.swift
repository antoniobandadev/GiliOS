//
//  PostServiceManager.swift
//  Gil
//
//  Created by Antonio Banda  on 09/05/25.
//
import UIKit
import Foundation
import Alamofire


class ServiceManager{
    
    static let shared = ServiceManager()
    
    private init(){}
    
    
    // MARK: - LogIn, SignIn, ForgotPassword
    
    func createUser(user : UserDto, completion: @escaping (Result<UserDto, Error>) -> Void) {
        let url = EndPoint.newUser.url
        
        AF.request(url, method: .post, parameters: user, encoder: JSONParameterEncoder.default)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: UserDto.self) { response in
                if let statusCode = response.response?.statusCode, statusCode == 409 {
                    let unauthorizedError = APIError.unauthorized
                    print("Email ya existe")
                    completion(.failure(unauthorizedError))
                    //return
                }else{
                    switch response.result {
                    case .success(let user):
                        completion(.success(user))
                    case .failure(let error):
                        let apiError = ErrorParser.parse(error)
                        completion(.failure(error))
                        print(apiError.localizedDescription)
                    }
                }
            }
    }
    
    func loginUser(user : UserDto, completion: @escaping (Result<UserDto, Error>) -> Void) {
        let url = EndPoint.logUser.url
        
        AF.request(url, method: .post, parameters: user, encoder: JSONParameterEncoder.default)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: UserDto.self) { response in
                print(response.result)
               if let statusCode = response.response?.statusCode, statusCode == 401 {
                   let unauthorizedError = APIError.unauthorized
                   print("No se encontro el usuario")
                   completion(.failure(unauthorizedError))
                   //return
               }else{
                   switch response.result {
                   case .success(let user):
                       print(user)
                       completion(.success(user))
                   case .failure(let error):
                       let apiError = ErrorParser.parse(error)
                       completion(.failure(error))
                       print(apiError.localizedDescription)
                   }
               }
                
                
            }
    }
    
    func forgotPass(forgotPass : ForgotPassReqDto, completion: @escaping (Result<ForgotPassDto, Error>) -> Void) {
        let url = EndPoint.forgotPassword.url
        
        AF.request(url, method: .post, parameters: forgotPass, encoder: JSONParameterEncoder.default)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: ForgotPassDto.self) { response in
                switch response.result {
                case .success(let forgotPassDto):
                    completion(.success(forgotPassDto))
                    
                case .failure(let error):
                    // Obtener el código de estado
                    if let statusCode = response.response?.statusCode {
                        switch statusCode {
                        case 401:
                            print("No se encontró el usuario")
                            completion(.failure(APIError.unauthorized))
                        case 404:
                            print("Recurso no encontrado")
                            completion(.failure(APIError.notFound))
                        default:
                            let parsedError = ErrorParser.parse(error)
                            print(parsedError.localizedDescription)
                            completion(.failure(parsedError))
                        }
                    } else {
                        // Error sin statusCode (por ejemplo, sin conexión)
                        completion(.failure(error))
                    }
                }
            }
    }
    
    func UpdatePassword(updatePass : UpdatePassDto, completion: @escaping (Result<Int, Error>) -> Void) {
        let url = EndPoint.updatePassword.url
        
        AF.request(url, method: .put, parameters: updatePass, encoder: JSONParameterEncoder.default)
            .validate(statusCode: 200..<300)
            .response{ response in
                if let statusCode = response.response?.statusCode {
                    switch statusCode {
                    case 200:
                        completion(.success(statusCode)) // o nil, o un DTO vacío, según tu necesidad
                    default:
                        let error = NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "StatusCode: \(statusCode)"])
                        completion(.failure(error))
                    }
                } else if let error = response.error {
                    completion(.failure(error))
                } else {
                    let unknownError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error desconocido"])
                    completion(.failure(unknownError))
                }
            }
    }
    
    // MARK: - Contacts
    
    func createContact(contact : ContactDto, completion: @escaping (Result<Int, Error>) -> Void){
        let url = EndPoint.newContact.url
        
        AF.request(url, method: .post, parameters: contact, encoder: JSONParameterEncoder.default)
        
        .validate(statusCode: 200..<300)
        .response{ response in
            if let statusCode = response.response?.statusCode {
                switch statusCode {
                case 200:
                    completion(.success(statusCode))
                default:
                    let error = NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "StatusCode: \(statusCode)"])
                    completion(.failure(error))
                }
            }else if let error = response.error {
                completion(.failure(error))
            }else {
                let unknownError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error desconocido"])
                completion(.failure(unknownError))
            }
        }
    }
    
    
    func updateContact(contact : ContactDto, completion: @escaping (Result<Int, Error>) -> Void){
        let url = EndPoint.updateContact.url
        
        AF.request(url, method: .post, parameters: contact, encoder: JSONParameterEncoder.default)
        
        .validate(statusCode: 200..<300)
        .response{ response in
            if let statusCode = response.response?.statusCode {
                switch statusCode {
                case 200:
                    completion(.success(statusCode))
                default:
                    let error = NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "StatusCode: \(statusCode)"])
                    completion(.failure(error))
                }
            }else if let error = response.error {
                completion(.failure(error))
            }else {
                let unknownError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error desconocido"])
                completion(.failure(unknownError))
            }
        }
    }
    
    func getContacts(userId : Int, completion: @escaping (Result<[ContactDto], Error>) -> Void){
        let url = EndPoint.getContacts.url
        
        AF.request(url, method: .get, parameters: ["userId": userId], encoding: URLEncoding.default)
        .validate(statusCode: 200..<300)
        .responseDecodable(of: [ContactDto].self) { response in
            
            switch response.result {
                case .success(let contactsApi):
                    completion(.success(contactsApi))
                case .failure(let error):
                    let apiError = ErrorParser.parse(error)
                    completion(.failure(error))
                    print(apiError.localizedDescription)
            }
        }
    }
    
    func getFriends(userId: Int, friendStatus: String, completion: @escaping (Result<[FriendDto], Error>) -> Void){
        let url = EndPoint.getFriends.url
        
        AF.request(url, method: .get, parameters: ["userId": userId, "friendStatus": friendStatus], encoding: URLEncoding.default)
        .validate(statusCode: 200..<300)
        .responseDecodable(of: [FriendDto].self) { response in
            
            if let statusCode = response.response?.statusCode, statusCode == 404 {
                let notFound = APIError.notFound
                completion(.failure(notFound))
                //return
            }else{
                
                switch response.result {
                case .success(let friends):
                    completion(.success(friends))
                case .failure(let error):
                    let apiError = ErrorParser.parse(error)
                    completion(.failure(error))
                    print(apiError.localizedDescription)
                }
            }
        }
    }
    
    
    func newFriends(friend: FriendDto, completion: @escaping (Result<Int, Error>) -> Void){
        let url = EndPoint.newFriend.url
        
        AF.request(url, method: .post, parameters: friend, encoder: JSONParameterEncoder.default)
        .validate(statusCode: 200..<500)
        .response{ response in
            if let statusCode = response.response?.statusCode {
                switch statusCode {
                case 200:
                    completion(.success(statusCode))
                case 401:
                    let unauthorizedError = APIError.unauthorized
                    print("Pendiente de respuesta")
                    completion(.failure(unauthorizedError))
                case 402:let unauthorizedError = APIError.process
                    print("Ya es amigo")
                    completion(.failure(unauthorizedError))
                case 404:
                    let unauthorizedError = APIError.notFound
                    print("Email no existe valido")
                    completion(.failure(unauthorizedError))
                default:
                    let error = NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "StatusCode: \(statusCode)"])
                    completion(.failure(error))
                }
            }else if let error = response.error {
                completion(.failure(error))
            }else {
                let unknownError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error desconocido"])
                completion(.failure(unknownError))
            }
        }
    }
    
    func solFriends(solFriend: SolFriendDto, completion: @escaping (Result<Int, Error>) -> Void){
        let url = EndPoint.solFriend.url
        
        AF.request(url, method: .put, parameters: solFriend, encoder: JSONParameterEncoder.default)
        .validate(statusCode: 200..<300)
        .response{ response in
            if let statusCode = response.response?.statusCode {
                switch statusCode {
                case 200:
                    completion(.success(statusCode))
                default:
                    let error = NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "StatusCode: \(statusCode)"])
                    completion(.failure(error))
                }
            }else if let error = response.error {
                completion(.failure(error))
            }else {
                let unknownError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error desconocido"])
                completion(.failure(unknownError))
            }
        }
    }
    
    //MARK: Events
    func uploadEvent(image: UIImage?, fileName: String = "imagen.jpg", event: EventEntity,
                     completion: @escaping (Result<EventDto, Error>) -> Void) {
        let url = EndPoint.newEvent.url
        
        let parameters: [String: String] = [
                "eventName": event.eventName ?? "",
                "eventDesc": event.eventDesc ?? "",
                "eventType": event.eventType ?? "",
                "eventDateStart": event.eventDateStart ?? "",
                "eventDateEnd": event.eventDateEnd ?? "",
                "eventStreet": event.eventStreet ?? "",
                "eventCity": event.eventCity ?? "",
                "eventStatus": event.eventStatus ?? "",
                "userId": String(event.userId),
                "userIdScan": String(event.userIdScan)
            ]

        AF.upload(
            multipartFormData: { multipartFormData in
                for (key, value) in parameters {
                    multipartFormData.append(Data(value.utf8), withName: key)
                }
                
                if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
                    multipartFormData.append(
                        imageData,
                        withName: "eventImage",
                        fileName: fileName,
                        mimeType: "image/jpeg"
                    )
                }
            },
            to: url,
            method: .post
        )
        .validate()
        .responseDecodable(of: EventDto.self) { response in
            switch response.result {
            case .success(let event):
                print("Éxito:")
                completion(.success(event))
                
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
    }
    
    func updateEvent(image: UIImage?, fileName: String = "imagen.jpg", event: EventEntity,
                     completion: @escaping (Result<EventDto, Error>) -> Void) {
        let url = EndPoint.updateEvent.url
        
        let parameters: [String: String] = [
                "eventName": event.eventName ?? "",
                "eventDesc": event.eventDesc ?? "",
                "eventType": event.eventType ?? "",
                "eventDateStart": event.eventDateStart ?? "",
                "eventDateEnd": event.eventDateEnd ?? "",
                "eventStreet": event.eventStreet ?? "",
                "eventCity": event.eventCity ?? "",
                "eventStatus": event.eventStatus ?? "",
                "userId": String(event.userId),
                "userIdScan": String(event.userIdScan)
            ]

        AF.upload(
            multipartFormData: { multipartFormData in
                for (key, value) in parameters {
                    multipartFormData.append(Data(value.utf8), withName: key)
                }
                
                if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
                    multipartFormData.append(
                        imageData,
                        withName: "eventImage",
                        fileName: fileName,
                        mimeType: "image/jpeg"
                    )
                }
            },
            to: url,
            method: .post
        )
        .validate()
        .responseDecodable(of: EventDto.self) { response in
            switch response.result {
            case .success(let event):
                print("Éxito:")
                completion(.success(event))
                
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
    }
    
    func getEvents(userId : Int, completion: @escaping (Result<[EventDto], Error>) -> Void){
        let url = EndPoint.getEvent.url
        
        AF.request(url, method: .get, parameters: ["userId": userId], encoding: URLEncoding.default)
        .validate(statusCode: 200..<300)
        .responseDecodable(of: [EventDto].self) { response in
            //debugPrint(response)
            switch response.result {
                case .success(let eventsApi):
                    completion(.success(eventsApi))
                case .failure(let error):
                    let apiError = ErrorParser.parse(error)
                    completion(.failure(error))
                    print(apiError.localizedDescription)
            }
        }
    }
    
    
    
    
    //MARK: Settings
    func uploadProfileImage(image: UIImage, fileName: String = "imagen.jpg", userId : Int) {
        let url = EndPoint.profileUser.url

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("No se pudo convertir la imagen a Data")
            return
        }

        // 2. Encabezados opcionales
        let headers: HTTPHeaders = [
            "Authorization": "Bearer tu_token_si_aplica",
            "Content-type": "multipart/form-data"
        ]

       
        AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(imageData, withName: "userProfile", fileName: fileName, mimeType: "image/jpeg")
                multipartFormData.append(Data(String(userId).utf8), withName: "userId")
            },
            to: url,
            method: .post,
            headers: headers
        )
        .response { response in
            switch response.result {
            case .success:
                print("Imagen subida con éxito")
            case .failure(let error):
                print("Error al subir imagen: \(error.localizedDescription)")
            }
        }
    }
    
    func updateName(userId: Int, userName: String, completion: @escaping (Result<Int, Error>) -> Void){
        let url = EndPoint.updateUserName.url
        
        AF.request(url, method: .post, parameters: ["userId": String(userId), "userName": userName], encoder: JSONParameterEncoder.default)
        .validate(statusCode: 200..<300)
        .response{ response in
            if let statusCode = response.response?.statusCode {
                switch statusCode {
                case 200:
                    completion(.success(statusCode))
                default:
                    let error = NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "StatusCode: \(statusCode)"])
                    completion(.failure(error))
                }
            }else if let error = response.error {
                completion(.failure(error))
            }else {
                let unknownError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error desconocido"])
                completion(.failure(unknownError))
            }
        }
    }
    
    
    
}


