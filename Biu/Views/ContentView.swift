//
//  ContentView.swift
//  Biu
//
//  Created by Zerui Chen on 4/7/20.
//

import SwiftUI
import Nuke

struct ContentView: View {
    
    @State private var selection = 1
    
    let favouriteViewModel = FavouriteModel()
    let mediaPlayerModel = MediaPlayerModel()
    
    var body: some View {
//        TabView(selection: $selection) {
//            FavouriteView()
//                .tabItem {
//                    Image(systemName: selection == 1 ? "cube.box.fill":"cube.box")
//                    Text("收藏")
//                }.tag(1)
//
//            Text("下载").tabItem {
//                    Image(systemName: selection == 2 ? "tray.fill":"tray")
//                    Text("下载")
//                }.tag(2)
//        }
//        .environmentObject(favouriteViewModel)
        MediaPlayerView()
        .environmentObject(mediaPlayerModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
