//
//  BKPassportEndpoint.swift
//  BiliKit
//
//  Created by Zerui Chen on 5/7/20.
//

import Foundation

/// The authentication endpoint.
public enum BKPassportEndpoint: String, BKEndpoint {
    
    // MARK: Endpoints
    case getKey = "/api/oauth2/getKey"
    case login = "/api/v3/oauth2/login"
    
    public var baseURL: URL {
        URL(string: "https://passport.bilibili.com")!
    }
    
    // MARK: Request Creation
    public static func createGetKeyRequest() -> BKRequest<GetKeyResponse> {
        BKPassportEndpoint.getKey.createRequest(using: .post)
    }
    
    /// Creates a login request. This is the only request not meant to be directly called with .fetch(), use instead BKClient's login methods.
    public static func createLoginRequest(username: String, password: String,
                                          otherParams: [String:String]? = nil) -> BKRequest<LoginResponse> {
        var params = otherParams ?? [:]
        params["username"] = username
        params["password"] = password
        return BKPassportEndpoint.login.createRequest(using: .post, withQuery: params)
    }
}
