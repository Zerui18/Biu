//
//  BKPassportModels.swift
//  BiliKit
//
//  Created by Zerui Chen on 6/7/20.
//

import Foundation

extension BKPassportEndpoint {
    
    // MARK: Get Key
    public struct GetKeyResponse: Codable {
        public let key: String
        public let hash: String
    }
    
    // MARK: Login
    public struct LoginResponse: Codable {
        public let cookieInfo: CookieInfo
        public let sso: [String]
        public let status: Int
        public let tokenInfo: TokenInfo
        public let url: URL?
        
        public var userId: Int {
            tokenInfo.mid
        }
        
        public var accessToken: String {
            tokenInfo.accessToken
        }
        
        public struct CookieInfo: Codable {
            public let cookies: [Cookie]
            public let domains: [String]
            
            public struct Cookie: Codable {
                public let expires: Int
                public let httpOnly: Int
                public let name: String
                public let value: String
                
                public enum CodingKeys: String, CodingKey {
                    case expires, httpOnly = "http_only", name, value
                }
            }
        }
        
        public struct TokenInfo: Codable {
            public let accessToken: String
            public let expiresIn: Int
            public let mid: Int
            public let refreshToken: String
            
            public enum CodingKeys: String, CodingKey {
                case accessToken = "access_token", expiresIn = "expires_in", mid, refreshToken = "refresh_token"
            }
        }
        
        public enum CodingKeys: String, CodingKey {
            case cookieInfo = "cookie_info", sso, status, tokenInfo = "token_info", url
        }
    }
    
    public struct GetQRCodeResponse: Codable {
        public let url: URL
        public let oauthKey: String
    }
    
    /// Wrapper for fetching login info.
    public struct LoginInfoResponse: Codable {
        /// If has login info.
        /// Set-Cookie if true.
        let status: Bool
        /// Login process status.
        /// - See: LoginState.of(_:).
        let data: Int
        /// Login process status explaination.
        let message: String
    }
    
    public struct Oauth2Info: Codable {
        let accessToken: String
        let expiresIn: Int
        let mid: Int
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token", expiresIn = "expires_in", mid
        }
    }

//    /// Stage during login process.
//    public enum LoginState {
//        case errored
//        case started
//        case needsConfirmation
//        case succeeded(cookies: [String])
//        case expired
//        case missingOAuthKey
//        case unknown(status: Int)
//        fileprivate static func of(_ info: LoginInfo) -> LoginState {
//            switch info.data {
//            case -1: return .missingOAuthKey
//            case -2: return .expired
//            case -4: return .started
//            case -5: return .needsConfirmation
//            default: return .unknown(status: info.data)
//            }
//        }
//    }

}
