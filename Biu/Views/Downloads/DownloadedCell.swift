//
//  DownloadedCell.swift
//  Biu
//
//  Created by Zerui Chen on 10/8/20.
//

import SwiftUI


struct DownloadedCell: View {
    
    init(media: SavedMedia) {
        self.media = media
        self.thumbnailImage = .init(url: media.thumbnailURL!)
    }
    
    @ObservedObject var thumbnailImage: FetchImage
    let media: SavedMedia
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                thumbnailImage.image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.width / 1.6)
                    .cornerRadius(12)
                
                Text(media.title!)
                    .font(Font.caption.bold())
                    .lineLimit(2)
                    .frame(maxWidth: geometry.size.width, alignment: .leading)
                    .padding([.leading, .trailing], 3)
                    .padding(.bottom, 0.01)
                
                Spacer()
                
                Text(media.owner!.name!)
                    .font(.caption)
                    .foregroundColor(Color(.secondaryLabel))
                    .lineLimit(1)
                    .frame(maxWidth: geometry.size.width, alignment: .leading)
                    .padding([.leading, .trailing, .bottom], 3)                
            }
        }
        .padding(8)
        .background(
            Color(.secondarySystemBackground)
                .cornerRadius(18)
        )
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
//        return DownloadedCell(media: newMedia)
//    }
//}
