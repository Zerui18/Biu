//
//  PlaylistView.swift
//  Biu
//
//  Created by Zerui Chen on 21/8/20.
//

import SwiftUI

struct PlaylistView: View {
    
    @ObservedObject var model: MediaPlayerModel = .shared
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct PlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistView()
    }
}
