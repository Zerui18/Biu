//
//  DownloadsItemCell.swift
//  Biu
//
//  Created by Zerui Chen on 15/7/20.
//

import SwiftUI
import Combine
import Tetra

struct DownloadsItemCell: View {
    
    init(media: SavedMedia, downloadStatePublisher: AnyPublisher<TTask.State, Never>) {
        self.media = media
        self.downloadStatePublisher = downloadStatePublisher
        self.thumbnailImage = FetchImage(placeholder: UIImage(named: "bg_placeholder")!,
                                         url: media.thumbnailURL!)
    }
    
    let media: SavedMedia
    var downloadStatePublisher: AnyPublisher<TTask.State, Never>
    
    @State var downloadState = TTask.State.paused
    @State var percentCompleted = 0.0
    @ObservedObject var thumbnailImage: FetchImage
    
    var body: some View {
        HStack {
            
            // Thumbnail.
            thumbnailImage.image
                .resizable()
                .frame(width: 70 * 1.6, height: 70)
                .cornerRadius(7)

            Spacer()
                .frame(width: 10)

            // Title & duration/count & downloaded.
            VStack(alignment: .leading) {
                Text(media.title!)
                    .font(.subheadline)
                    .lineLimit(2)
                    .layoutPriority(1)

                Spacer()

                ProgressBar(value: $percentCompleted, maxValue: .constant(1))
                    .frame(height: 2)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color(.secondarySystemBackground)
                .cornerRadius(10)
        )
        .onReceive(downloadStatePublisher) { state in
            downloadState = state
            if case .downloading(let progress) = state {
                self.percentCompleted = progress
            }
        }
    }
}

//struct DownloadsListView_Previews: PreviewProvider {
//    static var previews: some View {
//        DownloadsItemCell(savedMedia: <#T##SavedMedia#>, downloadState: <#T##Binding<TTask.State>#>)
//    }
//}
