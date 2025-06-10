//
//  ErrorParser.swift
//  Gil
//
//  Created by Antonio Banda  on 09/05/25.
//
import Foundation
import Alamofire

struct ErrorParser {
    static func parse(_ error: Error) -> APIError {
        if let afError = error as? AFError {
            return parseAFError(afError)
        }
        return .unknown(error)
    }
    
    private static func parseAFError(_ error: AFError) -> APIError {
        switch error {
        case .sessionTaskFailed(let underlyingError):
            return parseSessionTaskError(underlyingError)
            
        case .responseValidationFailed(let reason):
            return parseValidationFailed(reason)
            
        case .responseSerializationFailed(let reason):
            return parseSerializationFailed(reason)
            
        case .invalidURL:
            return .invalidRequest
            
        default:
            return .unknown(error)
        }
    }
    
    private static func parseSessionTaskError(_ error: Error) -> APIError {
        let nsError = error as NSError
        
        switch nsError.code {
        case NSURLErrorNotConnectedToInternet, NSURLErrorCannotConnectToHost:
            return .noInternetConnection
        case NSURLErrorTimedOut:
            return .timeout
        default:
            return .unknown(error)
        }
    }
    
    private static func parseValidationFailed(_ reason: AFError.ResponseValidationFailureReason) -> APIError {
        switch reason {
        case .unacceptableStatusCode(let code):
            switch code {
            case 401: return .unauthorized
            case 403: return .forbidden
            case 404: return .notFound
            case 400..<500: return .invalidRequest
            case 500..<600: return .serverError(statusCode: code, message: nil)
            default: return .unknown(AFError.responseValidationFailed(reason: reason))
            }
        default:
            return .unknown(AFError.responseValidationFailed(reason: reason))
        }
    }
    
    private static func parseSerializationFailed(_ reason: AFError.ResponseSerializationFailureReason) -> APIError {
        switch reason {
        case .decodingFailed(let error):
            return .decodingFailed(underlyingError: error)
        default:
            return .unknown(AFError.responseSerializationFailed(reason: reason))
        }
    }
}
