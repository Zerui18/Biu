//
//  CredentialsLogin.swift
//  Biu
//
//  Created by Zerui Chen on 3/7/20.
//

import SwiftUI

struct BottomLineTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        VStack() {
            configuration

            Rectangle()
                .frame(height: 2, alignment: .bottom)
                .foregroundColor(Color.accentColor.opacity(0.6))
        }
    }
}

struct CredentialsLoginView: View {
    
    @ObservedObject var model = LoginModel.shared
    
    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                
                TextField("Username", text:
                            $model.username)
                    .frame(maxWidth: 240)
                
                SecureField("Password", text: $model.password)
                    .frame(maxWidth: 240)
                
                Spacer()
                    .frame(height: 0)
                
                if !model.username.isEmpty && !model.password.isEmpty {
                    Button("Login") {
                        model.beginLogin()
                    }
                    .foregroundColor(.white)
                    .font(.title)
                    .frame(width: 240, height: 56)
                    .background(Color.accentColor)
                    .cornerRadius(28)
                }
            }
            .zIndex(0)
            
            if case let .captchaNeeded(url) = model.loginState, model.captchaValidate == nil {
                CaptchaWebview(url: url, validate: $model.captchaValidate)
            }
        }
        .textFieldStyle(BottomLineTextFieldStyle())
        .animation(.easeIn)
    }
}

struct CredentialsLogin_Previews: PreviewProvider {
    static var previews: some View {
        CredentialsLoginView()
    }
}
