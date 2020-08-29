//
//  ContentView.swift
//  Biu
//
//  Created by Zerui Chen on 4/7/20.
//

import SwiftUI

let isPad = UIDevice.current.userInterfaceIdiom == .pad

struct ContentView: View {
        
    @State private var presentingLogin = false
    
    var body: some View {
        ZStack {
            if !presentingLogin {
                UIKitTabView([
                    .init(view: FavouriteView(),
                          barItem:
                            .init(title: "收藏",
                                  image: UIImage(systemName: "cube.box"),
                                  selectedImage: UIImage(systemName: "cube.box.fill"))
                    ),
                    .init(view: DownloadsView(),
                          barItem:
                            .init(title: "下载",
                                  image: UIImage(systemName: "tray"),
                                  selectedImage: UIImage(systemName: "tray.fill")))
                ])
            }
            else {
                Spacer()
            }
            
            MediaPlayerContainerView()
                .zIndex(1)
            
            PopMenuView()
                .zIndex(2)

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
