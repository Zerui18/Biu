//
//  MediaPlayerContainerView.swift
//  Biu
//
//  Created by Zerui Chen on 17/7/20.
//

import SwiftUI

struct MediaPlayerContainerView: View {
    
    @State private var isPlayerExpanded = false {
        didSet {
            dragOffset = .zero
        }
    }
    @State private var shouldDisableDrag = false
    @State private var dragOffset = CGSize.zero
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all)
                .opacity(isPlayerExpanded ? 0.4:0)
                .animation(.linear)
                .zIndex(0)
                        
            MediaPlayerView(isExpanded: $isPlayerExpanded, shouldDisableDrag: $shouldDisableDrag)
                // Don't fill the width.
                .padding([.leading, .trailing], isPlayerExpanded ? 0:10)
                // Pad top when expended.
                .padding(.top, isPlayerExpanded ? 60:0)
                // Set height.
                .frame(maxHeight: isPlayerExpanded ? .infinity:80)
                // Ignore bottom safe area when expanded.
                .edgesIgnoringSafeArea(.bottom)
                // Offset from bottom when collapsed.
                .offset(y: isPlayerExpanded ? 0:-65)
                // Open/close.
                .onTapGesture {
                    isPlayerExpanded.toggle()
                }
                // Fun dragging effect.
                .gesture(DragGesture(minimumDistance: 0,
                                     coordinateSpace: .global)
                            .onChanged { gesture in
                                // Player collapsed, apply drag effect & drag up.
                                if !isPlayerExpanded {
                                    dragOffset = gesture.translation
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
                                // No transition activated, return offset to zero.
                                else {
                                    dragOffset = .zero
                                }
                            }, including: shouldDisableDrag ? .subviews:.all)
                .offset(dragOffset.compressed)
                .animation(.interactiveSpring())
                .zIndex(1)
        }
    }
}

struct MediaPlayerContainerView_Previews: PreviewProvider {
    static var previews: some View {
        MediaPlayerContainerView()
    }
}
