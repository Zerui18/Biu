//
//  BKClient.swift
//  BiliKit
//
//  Created by Zerui Chen on 6/7/20.
//

import Foundation
import Combine

public class BKClient {
    
    // MARK: Private Init
    private init() {}
    
    // MARK: Privae Properties
    private var loginResponse: BKResponse<BKPassportEndpoint.LoginResponse>? = {
        // Try fetching from UserDefaults during init
        return UserDefaults.standard.data(forKey: "loginResponse")
            .flatMap {
                try? JSONDecoder().decode(BKResponse<BKPassportEndpoint.LoginResponse>.self, from: $0)
            }
    }() {
        // Write newValue into UserDefaults
        didSet {
            if let data = loginResponse.flatMap({ try? JSONEncoder().encode($0) }) {
                UserDefaults.standard.setValue(data, forKey: "loginResponse")
            }
            else {
                UserDefaults.standard.removeObject(forKey: "loginResponse")
            }
        }
    }
    
    // MARK: Singleton
    public static let shared = BKClient()
    
    // MARK: Private Methods
    private typealias LoginPublisher = AnyPublisher<BKResponse<BKPassportEndpoint.LoginResponse>, BKError>
    private func _login(username: String, password: String, captcha: [String:String]?) -> LoginPublisher {
        BKPassportEndpoint.createGetKeyRequest()
            .fetch()
            .flatMap { keyResponse -> LoginPublisher in
                let hash = keyResponse.data.hash
                let key = keyResponse.data.key
                
                let encodedPwd = BKSec.rsaEncrypt(hash + password, with: key)!
                let request = BKPassportEndpoint
                                .createLoginRequest(username: username, password: encodedPwd, otherParams: captcha)
                return request.fetch()
            }
            .map {
                self.loginResponse = $0
                return $0
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: Internal Methods
    /// Add headers which contain the authentication cookies, returns nil if no loginResponse found.
    func authenticateRequest(_ urlRequest: URLRequest) -> URLRequest? {
        if let cookies = loginResponse?.data.cookieInfo.cookies {
            let cookiesConcatenated = cookies.map { cookie in
                "\(cookie.name)=\(cookie.value)"
            }.sorted().joined(separator: ";") + ";"
            
            var request = urlRequest
            request.allHTTPHeaderFields!["Cookie"] = cookiesConcatenated
            return request
        }
        return nil
    }
    
    // MARK: Public API
    public func getUserInfo() -> BKUserInfo? {
        loginResponse.flatMap(BKUserInfo.init)
    }
    
    public func fromUserInfo<ResponseType: Codable>(transform: @escaping (BKUserInfo) -> AnyPublisher<BKResponse<ResponseType>, BKError>) -> AnyPublisher<BKResponse<ResponseType>, BKError> {
        if let loginResponse = loginResponse {
            if #available(iOS 14.0, *) {
                return Just(BKUserInfo(from: loginResponse))
                    .flatMap(transform)
                    .eraseToAnyPublisher()
            } else {
                // Fallback on earlier versions
            }
        }
        return Fail(error: BKError.authenticationNeeded)
            .eraseToAnyPublisher()
    }
    
    public enum LoginResult {
        case successful
        case credentialsError
        case captchaNeeded(url: URL)
        case unknownError(reason: String)
    }
    
    public func login(username: String, password: String,
                      captcha: [String:String]? = nil) -> AnyPublisher<LoginResult, BKError> {
        _login(username: username, password: password, captcha: captcha)
            .map { loginResponse in
                switch loginResponse.code {
                case 0:
                    // Check for rare cases where 0 but still needs captcha
                    if let url = loginResponse.data.url {
                        return LoginResult.captchaNeeded(url: url)
                    }
                    return LoginResult.successful
                case -629:
                    return LoginResult.credentialsError
                case -105:
                    let url = loginResponse.data.url!
                    return LoginResult.captchaNeeded(url: url)
                default:
                    return LoginResult.unknownError(reason: loginResponse.message ?? "???")
                }
            }
            .eraseToAnyPublisher()
    }
    
}
