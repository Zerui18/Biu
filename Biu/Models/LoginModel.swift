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
        case none, loading, error(String)
        
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
    
    @Published var captchaURL: URL? = nil
    
    /// QRCode to be displayed.
    @Published var qrCodeImage: Image? = nil
    /// Username entered.
    @Published var username = ""
    /// Password entered.
    @Published var password = ""
    
    private var loginCancellable: AnyCancellable?
    
    // MARK: Methods
    /// Begins the login process.
    func beginLogin() {
        loginState = .loading
        loginCancellable = BKClient.shared
            .login(username: username, password: password)
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
                    self.captchaURL = url
                case .unknownError(let desc):
                    self.loginState = .error(desc)
                case .credentialsError:
                    self.loginState = .error("用户名或密码错误")
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
//        BKSession.shared.login { [self] (loginURL) in
//            DispatchQueue.main.async {
//                qrCodeImage = loginURL.qrCode()
//                loginState = .none
//            }
//        } handleLoginState: { [self] (loginState) in
//            DispatchQueue.main.async {
//                switch loginState {
//                case .succeeded(_):
//                    loggedIn = true
//                case .started:
//                    // Normal login loop callbacks
//                    break
//                default:
//                    print("QRCode login error: ", loginState)
//                }
//            }
//        }

    }
}
