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
    
    @Published var isLoggedIn = false
    
    // MARK: Privae Properties
    private lazy var userPassport: BKUserPassport? = {
        // Try fetching from UserDefaults during init
        let cached = UserDefaults.standard.data(forKey: "ups")
            .flatMap {
                try? JSONDecoder().decode(BKUserPassport.self, from: $0)
            }
        if cached != nil {
            isLoggedIn = true
        }
        return cached
    }() {
        // Write newValue into UserDefaults
        didSet {
            if let data = userPassport.flatMap({ try? JSONEncoder().encode($0) }) {
                UserDefaults.standard.setValue(data, forKey: "ups")
                isLoggedIn = true
            }
            else {
                UserDefaults.standard.removeObject(forKey: "ups")
                isLoggedIn = false
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
                self.userPassport = .init(fromResponse: $0)
                return $0
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: Internal Methods
    /// Add headers which contain the authentication cookies, returns nil if no loginResponse found.
    func authenticateRequest(_ urlRequest: URLRequest) -> URLRequest? {
        if let cookies = userPassport?.concatenatedCookies {
            var request = urlRequest
            request.allHTTPHeaderFields!["Cookie"] = cookies
            return request
        }
        return nil
    }
    
    // MARK: Public API
    public func getUserId() -> Int? {
        userPassport?.mid
    }
    
    public func fromUserInfo<ResponseType: Codable>(transform: @escaping (BKUserPassport) -> AnyPublisher<BKResponse<ResponseType>, BKError>) -> AnyPublisher<BKResponse<ResponseType>, BKError> {
        if let passport = userPassport {
            return transform(passport)
        }
        return Fail(error: BKError.authenticationNeeded)
            .eraseToAnyPublisher()
    }
    
    public enum LoginResult {
        case successful
        case credentialsError
        case captchaNeeded(URL)
        case unknownError(String)
    }
    
    public func login(username: String, password: String,
                      captcha: [String:String]? = nil) -> AnyPublisher<LoginResult, BKError> {
        _login(username: username, password: password, captcha: captcha)
            .map { loginResponse in
                switch loginResponse.code {
                case 0:
                    // Check for rare cases where 0 but still needs captcha
                    if let url = loginResponse.data.url {
                        return LoginResult.captchaNeeded(url)
                    }
                    return LoginResult.successful
                case -629:
                    return LoginResult.credentialsError
                case -105:
                    let url = loginResponse.data.url!
                    return LoginResult.captchaNeeded(url)
                default:
                    return LoginResult.unknownError(loginResponse.message ?? "???")
                }
            }
            .eraseToAnyPublisher()
    }
    
    public func logout() {
        userPassport = nil
    }
    
}

/// Object storing the authentication info of a user.
public struct BKUserPassport: Codable {
    
    init(mid: Int, accessToken: String, concatenatedCookies: String) {
        self.mid = mid
        self.accessToken = accessToken
        self.concatenatedCookies = concatenatedCookies
    }
    
    init(fromResponse loginRespone: BKResponse<BKPassportEndpoint.LoginResponse>) {
        let cookies = loginRespone.data.cookieInfo.cookies
        let concatenatedCookies = cookies.reduce("") { header, cookie in
            "\(header)\(cookie.name)=\(cookie.value);"
        }
        self.init(mid: loginRespone.data.userId, accessToken: loginRespone.data.accessToken, concatenatedCookies: concatenatedCookies)
    }
    
    public let mid: Int
    public let accessToken: String
    public let concatenatedCookies: String
    
}
