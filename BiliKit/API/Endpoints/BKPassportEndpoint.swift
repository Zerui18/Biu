//
//  BKPassportEndpoint.swift
//  BiliKit
//
//  Created by Zerui Chen on 5/7/20.
//

import Foundation
import Combine

/// The authentication endpoint.
public enum BKPassportEndpoint: String, BKEndpoint {
    
    // MARK: Endpoints
    case getKey = "/api/oauth2/getKey"
    case login = "/api/v3/oauth2/login"
    case oauth2Info = "/api/v2/oauth2/info"
    case getQRCode = "/qrcode/getLoginUrl"
    case getQRLoginInfo = "/qrcode/getLoginInfo"
    
    public var baseURL: URL {
        URL(string: "https://passport.bilibili.com")!
    }
    
    // MARK: Request Creation
    public static func createGetKeyRequest() -> BKRequest {
        BKPassportEndpoint.getKey.createRequest(using: .post)
    }
    
    /// Creates a login request. This is the only request not meant to be directly called with .fetch(), use instead BKClient's login methods.
    public static func createLoginRequest(username: String, password: String,
                                          otherParams: [String:String]? = nil) -> BKRequest {
        var params = otherParams ?? [:]
        params["username"] = username
        params["password"] = password
        return BKPassportEndpoint.login.createRequest(using: .post, withQuery: params)
    }
    
    /// Check if the current user is logged in with a working access_token.
    public static func loginCheck() -> AnyPublisher<Bool, Never> {
        BKClient.shared.fromUserInfo { (passport) -> AnyPublisher<BKResponse<BKPassportEndpoint.Oauth2Info>, BKError> in
            BKPassportEndpoint.oauth2Info
                .createRequest(using: .get, withQuery: ["access_token" : passport.accessToken])
                .fetch()
        }
        .map { response in
            print("got oauth2Info: \(response)")
            return true
        }
        .mapError({ (err) -> BKError in
            print(err)
            return err
        })
        .replaceError(with: false)
        .eraseToAnyPublisher()
    }
    
    /// Creates a QRCode url request.
    public static func createGetQRCodeRequest() -> BKRequest {
        BKPassportEndpoint.getQRCode.createRequest(using: .get)
    }
    
    /// Creates a request to retrieve the current QRCode result given the oauth key.
    public static func createGetQRLoginResultRequest(oauthKey: String) -> URLRequest {
        var request = URLRequest(url: self.getQRLoginInfo.url)
        request.httpMethod = "post"
        request.httpBody = "oauthKey=\(oauthKey)".data(using: .utf8)!
        request.allHTTPHeaderFields = [RequestHeader.userAgent.rawValue : BKKeys.defaultUserAgent.rawValue]
        return request
    }
}
