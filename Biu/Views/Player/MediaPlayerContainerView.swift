//
//  MediaPlayerContainerView.swift
//  Biu
//
//  Created by Zerui Chen on 17/7/20.
//

import SwiftUI

struct MediaPlayerContainerView: View {
    
    @State private var isPlayerExpanded = false
    @State private var shouldDisableDrag = false
    @GestureState private var dragOffset: CGSize = .zero
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all)
                .opacity(isPlayerExpanded ? 0.4:0)
                .animation(.linear)
                .zIndex(0)
                // Dismiss player on tap.
                .onTapGesture {
                    if isPlayerExpanded {
                        isPlayerExpanded = false
                    }
                }
                        
            let mediaPlayer = MediaPlayerView(isExpanded: $isPlayerExpanded,
                                              shouldDisableDrag: $shouldDisableDrag)
                // Don't fill the width.
                .padding([.leading, .trailing], isPlayerExpanded ? 0:15)
                // Pad top when expended.
                .padding(.top, isPlayerExpanded ? 60:0)
                // Set height.
                .frame(maxWidth: 500, maxHeight: isPlayerExpanded ? 1000:80)
                // Ignore bottom safe area when expanded.
                .edgesIgnoringSafeArea(.bottom)
                // Offset from bottom when collapsed.
                .offset(y: isPlayerExpanded ? 0:-65)
                // Drag offset.
                .offset(dragOffset.compressed)
                .animation(.interactiveSpring())
                // Open/close.
                .onTapGesture {
                    isPlayerExpanded.toggle()
                }
            #if !targetEnvironment(macCatalyst)
                // Fun dragging effect.
                mediaPlayer.gesture(DragGesture(minimumDistance: 0,
                                     coordinateSpace: .global)
                            .onChanged { gesture in
                                // Player collapsed, apply drag effect & drag up.
                                if !isPlayerExpanded {
                                    if gesture.translation.height < -50 {
                                        isPlayerExpanded = true
                                    }
                                }
                                // Player expanded, look for drag down.
                                else if gesture.translation.height > 50 {
                                    isPlayerExpanded = false
                                }
                            }
                            .onEnded { gesture in
                                // Recognize swipes with sufficient velocity.
                                if !isPlayerExpanded && gesture.predictedEndTranslation.height < -150 {
                                    isPlayerExpanded = true
                                }
                                else if isPlayerExpanded && gesture.predictedEndTranslation.height > 150 {
                                    isPlayerExpanded = false
                                }
                            }
                            .updating($dragOffset) { (value, state, _) in
                                state = value.translation.compressed
                            }, including: shouldDisableDrag ? .subviews:.all)
                .zIndex(1)
            #else
                mediaPlayer
            #endif
        }
    }
}

struct MediaPlayerContainerView_Previews: PreviewProvider {
    static var previews: some View {
        MediaPlayerContainerView()
    }
}
