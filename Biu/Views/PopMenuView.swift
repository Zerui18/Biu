//
//  PopMenuView.swift
//  Biu
//
//  Created by Zerui Chen on 23/8/20.
//

import SwiftUI
import Tetra

struct PopMenuView: View {
    
    @ObservedObject var model: PopMenuModel = .shared
    
    var body: some View {
        if let media = model.selectedMedia {
            ZStack {
                Blur()
                    .onTapGesture {
                        model.selectedMedia = nil
                    }
                
                VStack(spacing: 20.p) {
                    
                    Spacer()
                    Spacer()
                    Spacer()
                    
                    MenuItem(title: "播放", icon: Image(systemName: "play")) {
                        MediaPlayerModel.shared.replaceQueue(withMedia: media)
                        model.selectedMedia = nil
                    }
                    MenuItem(title: "稍后播放", icon: Image(systemName: "chevron.right")) {
                        MediaPlayerModel.shared.addToQueue(media)
                        model.selectedMedia = nil
                    }
                    MenuItem(title: "最后播放", icon: Image(systemName: "chevron.right.2")) {
                        MediaPlayerModel.shared.addToQueue(media)
                        model.selectedMedia = nil
                    }
                    
                    if media.getDownloadTask().simpleState.value == .none {
                        Color.clear
                            .frame(height: 10.p)
                        MenuItem(title: "下载", icon: Image(systemName: "square.and.arrow.down")) {
                            DownloadsModel.shared.initiateDownload(forMedia: media)
                            model.selectedMedia = nil
                        }
                    }
                    
                    Spacer()
                }
                .padding([.leading, .trailing], 30)
            }
            .edgesIgnoringSafeArea(.all)
            .transition(AnyTransition.opacity.animation(.easeIn(duration: 0.2)))
        }
        else {
            Color.clear
        }
    }
}

struct MenuItem: View {
    let title: String
    let icon: Image
    let action: () -> Void
    
    var body: some View {
        HStack {
            icon
            Spacer()
            Text(title)
        }
        .padding(8)
        .card()
        .onTapGesture(perform: action)
    }
}

struct PopMenuView_Previews: PreviewProvider {
    static var previews: some View {
        PopMenuModel.shared.selectedMedia = PlaceHolders.resourceInfo
        return PopMenuView()
            .edgesIgnoringSafeArea(.all)
            .colorScheme(.dark)
    }
}
