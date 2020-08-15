//
//  MediaPlayerView.swift
//  Biu
//
//  Created by Zerui Chen on 11/7/20.
//

import SwiftUI

struct MediaPlayerView: View {
    
    @ObservedObject var model: MediaPlayerModel = .shared
    
    // MARK: Binding
    @Binding var isExpanded: Bool
    @Binding var shouldDisableDrag: Bool
    
    // MARK: State
    @State private var currentTime: TimeInterval = 50
    @State private var duration: TimeInterval = 100
    @State private var isSeeking = false
    @State private var thumbnailImage = Image("bg_placeholder")
    
    enum PlayState: String {
        case playing, paused, loading
    }
    @State private var playState = PlayState.loading
    
    // MARK: Helper
    func thumbnailSize(with containerSize: CGSize) -> CGSize {
        if isExpanded {
            let width = containerSize.width * 0.9
            return CGSize(width: width, height: width / 1.6)
        }
        else {
            let height = containerSize.height - 20
            return CGSize(width: height * 1.6, height: height)
        }
    }
    
    // MARK: Body
    var body: some View {
        GeometryReader { geometry in
            
            // Thumbnail
            let size = thumbnailSize(with: geometry.size)
            
            thumbnailImage
                .resizable()
                .frame(width: size.width, height: size.height)
                .cornerRadius(size.height * 0.1)
                .offset(x: isExpanded ? 0:10, y: isExpanded ? 30:0)
                // Center vertically/horizontally.
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity,
                       alignment: isExpanded ? .top:.leading)
            
            // Title
            Text(model.title)
                .animation(nil)
                .font(isExpanded ? .headline:.subheadline)
                .lineLimit(2)
                .frame(maxWidth: isExpanded ?
                        size.width: geometry.size.width - size.width - 76,
                       maxHeight: isExpanded ? 60:.infinity)
                .padding(
                    EdgeInsets(top: isExpanded ? size.height + 60:0,
                               leading: isExpanded ? (geometry.size.width - size.width)/2:size.width+20,
                               bottom: 0, trailing: 0)
                )
            
            if isExpanded {
                VStack {
                    // Progress Slider.
                    Slider(value: $currentTime,
                           in: 0...duration,
                           onEditingChanged: { (isEditing) in
                                isSeeking = isEditing
                                shouldDisableDrag = isEditing
                                if isEditing {
                                    model.playPause()
                                }
                                else {
                                    // Seeking ended.
                                    model.seek(to: currentTime, play: true)
                                }
                            }
                    ) {
                        Text("hello")
                    }
                    .disabled(playState == .loading)

                    // Time labels.
                    HStack {
                        Text(currentTime.formattedDuration())
                            .foregroundColor(Color(.secondaryLabel))
                            .animation(nil)

                        Spacer()

                        Text(duration.formattedDuration())
                            .foregroundColor(Color(.secondaryLabel))
                            .animation(nil)
                    }
                    // A tiny bit of padding on both sides.
                    .padding([.leading, .trailing], 5)
                    .frame(maxWidth: .infinity)

                    Spacer()
                        .frame(height: 30)
                }
                .frame(maxWidth: size.width)
                // Center horizontally.
                .frame(maxWidth: .infinity)
                .padding(EdgeInsets(top: size.height + 150, leading: 0, bottom: 0, trailing: 0))
            }
            
            Button {
                model.playPause()
            } label: {
                let image = Image(systemName:
                                    playState != .playing ?
                                        "play.fill":"pause.fill")
                    .resizable()
                    .foregroundColor(.accentColor)

                if isExpanded {
                    image
                        .frame(width: 30, height: 36)
                }
                else {
                    image
                    .frame(width: 24, height: 30)
                }
            }
            .disabled(playState == .loading)
            .fixedSize()
            .padding(isExpanded ? .bottom:.trailing, isExpanded ? 200:20)
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity,
                   alignment: isExpanded ? .bottom:.trailing)
    
        }
        .background(
            Color(.secondarySystemBackground)
                // Faster expansion and normal speed for recall.
                .animation(.spring(response: isExpanded ? 0.4:0.55))
        )
        .cornerRadius(isExpanded ? 0:10)
        .animation(.spring())
        .onAppear {
            model.bind($playState, $isSeeking, $currentTime, $duration, $thumbnailImage)
        }
    }
}

struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        MediaPlayerView(isExpanded: .constant(false), shouldDisableDrag: .constant(true))
            .previewLayout(.fixed(width: 375, height: 80))
        
//        MediaPlayerView(isExpanded: .constant(true), shouldDisableDrag: .constant(true))
    }
}

// MARK: TimeInterval + Format
fileprivate extension TimeInterval {
    func formattedDuration() -> String {
        let intSelf = Int(self)
        let (hours, remainder) = intSelf.quotientAndRemainder(dividingBy: 3600)
        let (minutes, seconds) = remainder.quotientAndRemainder(dividingBy: 60)
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
