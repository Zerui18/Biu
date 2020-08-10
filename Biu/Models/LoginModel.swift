//
//  LoginModel.swift
//  Bili
//
//  Created by Zerui Chen on 3/7/20.
//

import UIKit
import SwiftUI
import Combine
import BiliKit

class LoginModel: ObservableObject {
    
    private init() {
        self.loggedIn = BKClient.shared.getUserId() != nil
    }
    
    // MARK: Singleton
    static var shared = LoginModel()
    
    // MARK: Enum
    
    enum LoginState {
        case none, loading, error(String), captchaNeeded(URL)
        
        var isLoading: Bool {
            switch self {
            case .loading:
                return true
            default:
                return false
            }
        }
    }
    
    enum LoginMode {
        case password, qrCode
    }
    
    // MARK: Published
    
    @Published var loggedIn = false
    
    @Published var loginState: LoginState = .none
    @Published var loginMode: LoginMode = .password
        
    /// QRCode to be displayed.
    @Published var qrCodeImage: Image? = nil
    /// Username entered.
    @Published var username = "84685638"
    /// Password entered.
    @Published var password = "A2Bzx578436"
    
    private var loginCancellable: AnyCancellable?
    private var qrCodeCancellable: AnyCancellable?
    
    @Published var captchaValidate: String?
    private var lastCaptchaChallenge: String?
    
    // MARK: Methods
    /// Begins the login process.
    func beginLogin() {
        loginState = .loading
        let captchaParams = lastCaptchaChallenge.flatMap { c in
            captchaValidate.flatMap { v in ["challenge": c, "seccode": "\(v)|jordan", "validate": v]
            }
        }
        // Clear captcha states.
        captchaValidate = nil
        lastCaptchaChallenge = nil
        // Start pipeline.
        loginCancellable = BKClient.shared
            .login(username: username, password: password, captcha: captchaParams)
            .receive(on: RunLoop.main)
            .sink { (completion) in
                if case .failure(let error) = completion {
                    self.loginState = .error(error.localizedDescription)
                }
            } receiveValue: { (result) in
                switch result {
                case .successful:
                    self.loggedIn = true
                case .captchaNeeded(let url):
                    self.lastCaptchaChallenge =
                        URLComponents(url: url, resolvingAgainstBaseURL: false)!.queryItems!
                            .first { $0.name == "challenge" }!.value!
                    self.loginState = .captchaNeeded(url)
                case .unknownError(let desc):
                    self.loginState = .error(desc)
                case .credentialsError:
                    self.loginState = .error("用户名或密码错误")
                case .waiting:
                    fatalError("Not applicable to credentials login.")
                }
            }
    }
    
    /// Logout synchronously.
    func logout() {
        BKClient.shared.logout()
        // reset properties
        username = ""
        password = ""
        loginMode = .password
        loginState = .none
        loggedIn = false
    }
    
    /// Begin generating qrCode.
    func beginQRCodeGeneration() {
        loginState = .loading
        
        let (qrCode, loginState) = BKClient.shared.qrLogin()
        
        qrCodeCancellable = qrCode
            .receive(on: RunLoop.main)
            .sink { (_) in
            } receiveValue: { (image) in
                self.loginState = .none
                self.qrCodeImage = .init(uiImage: image)
            }
        
        loginCancellable = loginState
            .receive(on: RunLoop.main)
            .sink { (completion) in
                if case .failure(let err) = completion {
                    self.loginState = .error(err.localizedDescription)
                }
            } receiveValue: { (result) in
                switch result {
                case .successful:
                    self.loggedIn = true
                case .captchaNeeded(_):
                    fatalError("Not applicable to qrcode login.")
                case .unknownError(let desc):
                    self.loginState = .error(desc)
                case .credentialsError:
                    fatalError("Not applicable to qrcode login.")
                case .waiting:
                    break
                }
            }
    }
}
