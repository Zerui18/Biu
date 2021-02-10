//
//  DownloadsItemCell.swift
//  Biu
//
//  Created by Zerui Chen on 15/7/20.
//

import SwiftUI
import Combine
import Tetra

struct DownloadingItemCell: View {
    
    init(media: SavedMedia) {
        self.media = media
        self.thumbnailImage = FetchImage(url: media.thumbnailURL!)
    }
    
    @ObservedObject var media: SavedMedia
    @State var downloadState = TTask.State.paused
    @State var percentCompleted = 0.0
    @ObservedObject var thumbnailImage: FetchImage
    
    var body: some View {
        HStack {
            
            // Thumbnail.
            thumbnailImage.image
                .frame(width: 70 * 1.6, height: 70)
                .cornerRadius(7)

            Spacer()
                .frame(width: 10)

            // Title & duration/count & downloaded.
            VStack(alignment: .leading) {
                Text(media.title!)
                    .font(.platformItemTitle)
                    .lineLimit(2)

                Spacer()

                if !media.isDownloaded {
                    if case let .downloading(progress) = media.downloadState {
                        ProgressBar(value: progress, maxValue: 1)
                            .frame(height: 3)
                    }
                    else if case let .failure(error) = media.downloadState {
                        Text(error.localizedDescription)
                            .font(.platformItemDesc)
                    }
                }
                else {
                    Text(Int(media.duration).formattedDuration())
                        .font(.platformItemTitle)
                        .foregroundColor(.gray)
                }
            }
        }
        .card()
    }
}

//struct DownloadsListView_Previews: PreviewProvider {
//    static var previews: some View {
//        DownloadsItemCell(savedMedia: <#T##SavedMedia#>, downloadState: <#T##Binding<TTask.State>#>)
//    }
//}
