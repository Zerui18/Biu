//
//  BKError.swift
//  BiliKit
//
//  Created by Zerui Chen on 6/7/20.
//

import Foundation

public enum BKError: Error {
    
    case loginError(reason: String)
    
    case networkError(reason: String)
    
    case decodingError(error: DecodingError, raw: String)
    
    case authenticationNeeded
    
}

extension BKError {
    
    public var title: String {
        switch self {
        case .loginError:
            return "Login Failed"
        case .networkError:
            return "Network Error"
        case .decodingError:
            return "Decoding Failed"
        case .authenticationNeeded:
            return "Login Needed"
        }
    }
    
    public var message: String? {
        switch self {
        case .loginError(reason: let reason):
            return reason
        case .networkError(reason: let reason):
            return reason
        case .decodingError:
            return nil
        case .authenticationNeeded:
            return nil
        }
    }
    
}
