//
//  ContentView.swift
//  Biu
//
//  Created by Zerui Chen on 4/7/20.
//

import SwiftUI

struct ContentView: View {
    
    @State private var selection = 1
    @State private var isPlayerExpanded = false
    
    let favouriteViewModel = FavouriteModel()
    let mediaPlayerModel = MediaPlayerModel()
    let downloadsModel = DownloadsModel()
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
            TabView(selection: $selection) {
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
            .zIndex(0)
            
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all)
                .opacity(isPlayerExpanded ? 0.4:0)
                .animation(.linear)
                .zIndex(0.5)
                        
            MediaPlayerView(isExpanded: $isPlayerExpanded)
                // Don't fill the width.
                .padding([.leading, .trailing], isPlayerExpanded ? 0:10)
                // Ignore bottom safe area when expanded.
                .edgesIgnoringSafeArea(.bottom)
                // Pad top when expended. to be moved...
                .padding(.top, isPlayerExpanded ? 60:0)
                // Offset from bottom when collapsed.
                .offset(y: isPlayerExpanded ? 0:-60)
                // Set height.
                .frame(maxHeight: isPlayerExpanded ? .infinity:80)
                // Open/close.
                .onTapGesture {
                    isPlayerExpanded.toggle()
                }
                .zIndex(1)
        }
        .environmentObject(favouriteViewModel)
        .environmentObject(mediaPlayerModel)
        .environmentObject(downloadsModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
