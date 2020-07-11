//
//  FavouriteFolderCell.swift
//  Biu
//
//  Created by Zerui Chen on 8/7/20.
//

import SwiftUI

/// Cell that displays a single folder.
struct FavouriteFolderCell: View {
    
    var folder: FavouriteFolderModel
    
    var body: some View {
        HStack {
            
            // Thumbnail.
            WebImageView(url: folder.thumbnailURL)
                .frame(width: 1.6 * 60, height: 60)
                .cornerRadius(5.0)

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
                .foregroundColor(Color(.systemFill))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        // Card background & shadow
        .background(
            Color(.secondarySystemBackground)
                .cornerRadius(20)
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
