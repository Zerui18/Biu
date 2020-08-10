//
//  BKClient.swift
//  BiliKit
//
//  Created by Zerui Chen on 6/7/20.
//

import UIKit
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
    
    /// Returns a publisher that performs the transform and throws .authenticationNeeded if no passport present.
    public func fromUserInfo<ResponseType: Codable>(transform: @escaping (BKUserPassport) -> AnyPublisher<BKResponse<ResponseType>, BKError>) -> AnyPublisher<BKResponse<ResponseType>, BKError> {
        Just(0)
            .setFailureType(to: BKError.self)
            .flatMap { _ -> AnyPublisher<BKResponse<ResponseType>, BKError> in
                if let passport = self.userPassport {
                    return transform(passport)
                }
                return Fail(error: BKError.authenticationNeeded)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    public enum LoginResult {
        case successful
        case credentialsError
        case captchaNeeded(URL)
        case unknownError(String)
        /// Special case for QRCode.
        case waiting
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
            // Catch edge case when captcha is needed
            // and the returned data is incomplete and
            // causes decoding error.
            .tryCatch { (error) -> Just<LoginResult> in
                if case let .decodingError(_, raw) = error,
                   let captchaNeededResponse = try? JSONDecoder().decode(BKResponse<CaptchaNeededResponse>.self, from: raw.data(using: .utf8)!) {
                    return Just(.captchaNeeded(captchaNeededResponse.data.url))
                }
                else {
                    throw error
                }
            }
            .print()
            .mapError { $0 as! BKError }
            .eraseToAnyPublisher()
    }
    
    public func qrLogin() -> (qrCode: AnyPublisher<UIImage, BKError>, loginResult: AnyPublisher<LoginResult, BKError>) {
        let qrcodeInfo = Deferred { Just(Date()) }
            .append(
                Timer.publish(every: 170, tolerance: 1, on: .main, in: .default, options: nil)
                .autoconnect())
            .setFailureType(to: BKError.self)
            .flatMap {_ in
                BKPassportEndpoint.createGetQRCodeRequest()
                    .fetch()
            }
        let qrCode = qrcodeInfo
            .map {
                $0.data.url.absoluteString.generateQRCode()!
            }
            .eraseToAnyPublisher()
        let loginResult = qrcodeInfo
            .flatMap(maxPublishers: .max(1)) { qrcodeInfo in
                Timer.publish(every: 1, tolerance: 0.2, on: .main, in: .default)
                    .autoconnect()
                    .setFailureType(to: BKError.self)
                    .flatMap(maxPublishers: .max(1)) {_ -> AnyPublisher<(BKPassportEndpoint.LoginInfoResponse, URLResponse), BKError> in
                        URLSession.shared.fetchWithResponse(BKPassportEndpoint.createGetQRLoginResultRequest(oauthKey: qrcodeInfo.data.oauthKey))
                    }
                    .print()
                    .map { info, response -> LoginResult in
                        if info.status {
                            // Save cookies.
                            let response = response as! HTTPURLResponse
                            let cookies = (response.allHeaderFields as! [String:String])["Set-Cookie"]
                            return .successful
                        }
                        else {
                            return .waiting
                        }
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        return (qrCode: qrCode, loginResult: loginResult)
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

fileprivate struct CaptchaNeededResponse: Codable {
    let url: URL
}
