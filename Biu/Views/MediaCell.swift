//
//  MediaCell.swift
//  Biu
//
//  Created by Zerui Chen on 10/8/20.
//

import SwiftUI


struct MediaCell: View {
    
    init(media: MediaRepresentable, showAuthor: Bool = true) {
        self.media = media
        self.thumbnailImage = .init(url: media.getThumbnailURL())
        self.compact = showAuthor
    }
    
    @ObservedObject var thumbnailImage: FetchImage
    let media: MediaRepresentable
    let compact: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                thumbnailImage.image
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.width / 1.6)
                    .cornerRadius(12)
                                
                Text(media.getCleanedTitle())
                    .font(.platformItemTitle)
                    .lineLimit(compact ? 3:2)
                    .frame(maxWidth: geometry.size.width, alignment: .leading)
                    .padding([.leading, .trailing], 3)
                    .padding(.bottom, 0.01)
                
                Spacer()
                
                if compact {
                    Text(media.getAuthor().getName())
                        .font(.caption)
                        .foregroundColor(Color(.secondaryLabel))
                        .lineLimit(1)
                        .frame(maxWidth: geometry.size.width, alignment: .leading)
                        .padding([.leading, .trailing, .bottom], 3)
                }
            }
        }
        .card(cornerRadius: 18)
    }
}

//struct DownloadedCell_Previews: PreviewProvider {
//    static var previews: some View {
//        let context = AppDelegate.shared.persistentContainer.viewContext
//        let newMedia = SavedMedia(context: context)
//        newMedia.title = "Media 1"
//        newMedia.owner = SavedUpper(context: context)
//        newMedia.owner!.name = "hanser"
//        newMedia.isDownloaded = true
//        return MediaCell(media: newMedia)
//    }
//}
