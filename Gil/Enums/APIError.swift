//
//  ApiError.swift
//  Gil
//
//  Created by Antonio Banda  on 09/05/25.
//

import Foundation
import Alamofire

enum APIError: Error {
    case noInternetConnection
    case timeout
    case serverError(statusCode: Int, message: String?)
    case decodingFailed(underlyingError: Error)
    case invalidRequest
    case unauthorized
    case forbidden
    case notFound
    case responseSerializationFailed
    case unknown(Error)
    case process
    
    var localizedDescription: String {
        switch self {
        case .noInternetConnection:
            return "Internet connection unavailable."
        case .timeout:
            return "The server is taking too long to respond. Please try again."
        case .serverError(let statusCode, _):
            return "Server error (Code: \(statusCode)). Please try again."
        case .decodingFailed:
            return "Error processing server response."
        case .invalidRequest:
            return "The request is not valid."
        case .unauthorized:
            return "You need to log in to access this content."
        case .process:
            return "You have a pending request."
        case .forbidden:
            return "You do not have permission to access this resource."
        case .notFound:
            return "The requested resource does not exist."
        case .responseSerializationFailed:
            return "Error parsing server response."
        case .unknown:
            return "An unexpected error occurred."
        }
    }
}
