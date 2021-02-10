//
//  MediaActionsButton.swift
//  Biu
//
//  Created by Zerui Chen on 1/9/20.
//

import SwiftUI

struct MediaActionsButton: View {
    let media: MediaRepresentable
    
    var body: some View {
        Image(systemName: "ellipsis")
            .resizable()
            .frame(width: 40.p, height: 40.p)
            .accentColor(.accentColor)
            .makeInteractive(media: media)
    }
}
