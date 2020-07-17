//
//  ContentView.swift
//  Biu
//
//  Created by Zerui Chen on 4/7/20.
//

import SwiftUI

struct ContentView: View {
    
    @State private var selection = 1
    
    @ObservedObject private var loginModal = LoginModel.shared
    @State private var presentingLogin = false
    
    var body: some View {
        ZStack {
            TabView(selection: $selection) {
                if loginModal.loggedIn {
                    FavouriteView()
                        .tabItem {
                            Image(systemName: selection == 1 ? "cube.box.fill":"cube.box")
                            Text("收藏")
                        }.tag(1)

                    DownloadsView()
                        .tabItem {
                            Image(systemName: selection == 2 ? "tray.fill":"tray")
                            Text("下载")
                        }.tag(2)
                }
            }
            .zIndex(0)
            
            MediaPlayerContainerView()
                .zIndex(1)
        }
        .onReceive(loginModal.$loggedIn) { loggedIn in
            presentingLogin = !loggedIn
        }
        .sheet(isPresented: $presentingLogin) {
            if !loginModal.loggedIn {
                presentingLogin = true
            }
        }
        content: {
            LoginView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
