//
//  MediaPlayerView.swift
//  Biu
//
//  Created by Zerui Chen on 11/7/20.
//

import SwiftUI

struct MediaPlayerView: View {
    
    @EnvironmentObject var model: MediaPlayerModel
    
    var body: some View {
        Text("Hi")
    }
}

struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        MediaPlayerView()
            .environmentObject(MediaPlayerModel())
    }
}
