//
//  FavouriteFolderCell.swift
//  Biu
//
//  Created by Zerui Chen on 8/7/20.
//

import SwiftUI

/// Cell that displays a single folder.
struct FavouriteFolderCell: View {
    
    init(folder: FavouriteFolderModel) {
        self.folder = folder
        self.thumbnailImage = FetchImage(placeholder: UIImage(named: "bg_placeholder")!, url: folder.thumbnailURL)
    }
    
    @ObservedObject var thumbnailImage: FetchImage
    
    var folder: FavouriteFolderModel
    
    var body: some View {
        HStack {
            
            // Thumbnail.
            thumbnailImage.image
                .resizable()
                .frame(width: 1.6 * 60, height: 60)
                .cornerRadius(5)

            Spacer()
                .frame(width: 10)

            // Title & count.
            VStack(alignment: .leading) {
                Text(folder.title)
                    .font(.subheadline)
                    .bold()
                    // For preview to render correctly
                    .foregroundColor(Color(.label))

                Spacer()

                Text("\(folder.mediaCount)个内容")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.title)
                .foregroundColor(Color("AccentColor"))
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        // Card background & shadow
        .background(
            Color(.secondarySystemBackground)
                .cornerRadius(10)
        )
    }
}

struct FavouriteFolderCell_Previews: PreviewProvider {
    static var previews: some View {
        FavouriteFolderCell(folder: PlaceHolders.favouriteFolder)
            .padding()
            .frame(width: 375, height: 60)
    }
}
