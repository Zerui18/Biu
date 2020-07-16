//
//  ContentView.swift
//  Biu
//
//  Created by Zerui Chen on 1/7/20.
//

import SwiftUI

struct LoginView: View {

    @ObservedObject var model = LoginModel.shared

    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                
                Spacer()
                
                Text("Login")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.accentColor)
                
                HStack(spacing: 20) {
                
                    let passwordOption =
                        Image(systemName: "text.cursor")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .onTapGesture {
                            model.loginMode = .password
                        }
                    
                    let qrcodeOption =
                        Image(systemName: "qrcode")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .onTapGesture {
                            model.loginMode = .qrCode
                        }
                    
                    if model.loginMode == .password {
                        passwordOption
                            .foregroundColor(.accentColor)
                        qrcodeOption
                            .foregroundColor(.gray)
                    }
                    else {
                        passwordOption
                            .foregroundColor(.gray)
                        qrcodeOption
                            .foregroundColor(.accentColor)
                    }
                }
                
                switch model.loginMode {
                case .password:
                    CredentialsLoginView()
                case .qrCode:
                    QRLoginView()
                }
                
                Spacer()
                Spacer()
            }
            
            Text("Loading")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Blur())
                .opacity(model.loginState.isLoading ? 1:0)
                .animation(.easeIn)
            
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}
