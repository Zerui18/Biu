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
    
    @ObservedObject var modal = LoginModel.shared
    
    var body: some View {
        VStack(spacing: 30) {
            
            TextField("Username", text:
                        $modal.username)
                .frame(maxWidth: 240)
            
            SecureField("Password", text: $modal.password)
                .frame(maxWidth: 240)
            
            Spacer()
                .frame(height: 0)
            
            if !modal.username.isEmpty && !modal.password.isEmpty {
                Button("Login", action: modal.beginLogin)
                .foregroundColor(.white)
                .font(.title)
                .frame(width: 240, height: 56)
                .background(Color.accentColor)
                .cornerRadius(28)
            }
        }
        .textFieldStyle(BottomLineTextFieldStyle())
        .transition(.slide)
        .animation(.easeIn)
    }
}

struct CredentialsLogin_Previews: PreviewProvider {
    static var previews: some View {
        CredentialsLoginView()
    }
}
