//
//  MediaPlayerView.swift
//  Biu
//
//  Created by Zerui Chen on 11/7/20.
//

import SwiftUI

struct MediaPlayerView: View {
    
    @State private var currentTime: TimeInterval = 0
    @State private var duration: TimeInterval = 0
    @State private var isSeeking = false
    @State private var isPaused = false
    
    @EnvironmentObject var model: MediaPlayerModel
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                if let item = model.currentItem {
                    WebImageView(url: item.thumbnailURL)
                        .frame(width: geometry.size.width * 0.95, height: geometry.size.width * 0.95 / 1.6)
                        .cornerRadius(10)
                    
                    Spacer()
                    
                    Text(item.title)
                        .font(.headline)
                    
                    Spacer()
                        .frame(height: 30)
                    
                    Slider(value: $currentTime,
                           in: 0...duration,
                           onEditingChanged: { (isEditing) in
                                isSeeking = isEditing
                            },
                           minimumValueLabel:
                            Text(currentTime.formattedDuration())
                            .foregroundColor(Color(.secondaryLabel)),
                           maximumValueLabel:
                            Text(duration.formattedDuration())
                            .foregroundColor(Color(.secondaryLabel))
                    ) {
                        Text("hello")
                    }
                    .animation(.easeIn)
                    
                    Spacer()
                        .frame(height: 30)
                    
                    Button {
                        isPaused.toggle()
                        model.setPaused(isPaused)
                    } label: {
                        Image(systemName: isPaused ? "play.circle.fill":"pause.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.accentColor)
                    }
                    
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                model.bind($isSeeking, $currentTime, $duration)
            }
        }
        .padding()
    }
}

struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        MediaPlayerView()
            .environmentObject(PlaceHolders.mediaPlayer)
    }
}

// MARK: TimeInterval + Format
fileprivate extension TimeInterval {
    func formattedDuration() -> String {
        let intSelf = Int(self)
        let (hours, remainder) = intSelf.quotientAndRemainder(dividingBy: 3600)
        let (minutes, seconds) = remainder.quotientAndRemainder(dividingBy: 60)
        if hours > 0 {
            return "\(hours):\(minutes):\(seconds)"
        }
        else {
            return "\(minutes):\(seconds)"
        }
    }
}
