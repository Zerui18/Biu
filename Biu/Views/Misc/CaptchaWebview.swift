//
//  CaptchaWebview.swift
//  Biu
//
//  Created by Zerui Chen on 20/7/20.
//

import SwiftUI
import WebKit
import Combine
import Interceptor

fileprivate struct AjaxResponse: Codable {
    let validate: String?
}

final class CaptchaWebview: UIViewRepresentable {
    
    init(url: URL, validate: Binding<String?>) {
        self._validate = validate
        if UIView().traitCollection.userInterfaceStyle == .dark {
            let raw = url.absoluteString
            self.url = URL(string: "\(raw)&night=true")!
            print(self.url)
        }
        else {
            self.url = url
        }
    }
    
    @Binding var validate: String?
    private let url: URL
    private var notificationCancellable: AnyCancellable?
    
    func makeUIView(context: Context) -> WKWebView {
        Interceptor.start()
        notificationCancellable = NotificationCenter.default.publisher(for: .init(rawValue: "interceptor_caught"), object: nil)
            .first()
            .map { notification in
                notification.object! as! URLRequest
            }
            .sink { request in
                Interceptor.stop()
                URLSession.shared.dataTask(with: request) { [weak self] (data, response, _) in
                    if let self = self,
                       let data = data {
                        let json = String(data: data, encoding: .utf8)!.components(separatedBy: "(")[1].dropLast(1)
                        let jsonObject = try! JSONDecoder().decode(AjaxResponse.self, from: json.data(using: .utf8)!)
                        DispatchQueue.main.async {
                            self.validate = jsonObject.validate
                            LoginModel.shared.beginLogin()
                        }
                    }
                }
                .resume()
            }
        let webview = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        webview.load(URLRequest(url: url))
        return webview
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if case let .captchaNeeded(url) = LoginModel.shared.loginState {
            Interceptor.start()
            notificationCancellable = NotificationCenter.default.publisher(for: .init(rawValue: "interceptor_caught"), object: nil)
                .first()
                .map { notification in
                    notification.object! as! URLRequest
                }
                .sink { request in
                    Interceptor.stop()
                    var request = request
                    request.setValue(self.url.absoluteString, forHTTPHeaderField: "referer")
                    URLSession.shared.dataTask(with: request) { [weak self] (data, response, _) in
                        if let self = self,
                           let data = data {
                            let json = String(data: data, encoding: .utf8)!.components(separatedBy: "(")[1].dropLast(1)
                            let jsonObject = try! JSONDecoder().decode(AjaxResponse.self, from: json.data(using: .utf8)!)
                            DispatchQueue.main.async {
                                self.validate = jsonObject.validate
                                LoginModel.shared.beginLogin()
                            }
                        }
                    }
                    .resume()
                }
            uiView.load(URLRequest(url: url))
        }
    }
    
    deinit {
        Interceptor.stop()
    }
    
}
