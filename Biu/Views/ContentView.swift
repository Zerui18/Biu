//
//  ContentView.swift
//  Biu
//
//  Created by Zerui Chen on 4/7/20.
//

import SwiftUI

fileprivate let selectionBinding = RootModel.shared.selectionBinding

struct ContentView: View {
        
    @State private var presentingLogin = false
    
    var body: some View {
        ZStack {
            TabView {
                if !presentingLogin {
                    FavouriteView()
                        .tabItem {
                            Image(systemName: "cube.box")
                            Text("收藏")
                        }.tag(1)

                    DownloadsView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .tabItem {
                            Image(systemName: "tray")
                            Text("下载")
                        }.tag(2)
                }
                else {
                    Spacer()
                }
            }
            .zIndex(0)
            
            MediaPlayerContainerView()
                .zIndex(1)

        }
        // Set presentingLogin based on $loggedIn.
        .onReceive(LoginModel.shared.$loggedIn) { loggedIn in
            presentingLogin = !loggedIn
        }
        // Re-present login if not logged in.
        .sheet(isPresented: $presentingLogin) {
            if !LoginModel.shared.loggedIn {
                presentingLogin = true
            }
        }
        content: {
            LoginView()
                .accentColor(Color("AccentColor"))
        }
        .accentColor(Color("AccentColor"))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .colorScheme(.dark)
    }
}
