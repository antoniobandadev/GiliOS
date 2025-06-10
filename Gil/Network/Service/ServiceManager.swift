//
//  PostServiceManager.swift
//  Gil
//
//  Created by Antonio Banda  on 09/05/25.
//

import Foundation
import Alamofire


class ServiceManager{
    
    static let shared = ServiceManager()
    
    private init(){}
    
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
    
    
}


