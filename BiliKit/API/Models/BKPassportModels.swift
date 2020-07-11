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

}
