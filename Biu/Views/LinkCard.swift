//
//  LinkCard.swift
//  Biu
//
//  Created by Zerui Chen on 8/7/20.
//

import SwiftUI

/// Cell that displays a single folder.
struct LinkCard: View {
    
    @ObservedObject var thumbnailImage: FetchImage
    
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack {
            
            // Thumbnail.
            if !isPad {
                thumbnailImage.image
                    .resizable()
                    .frame(width: 1.6 * 60, height: 60)
                    .background(Color.blue)
                    .cornerRadius(5)
            }

            Spacer()
                .frame(width: 10)

            // Title & count.
            VStack(alignment: .leading) {
                Text(title)
                    .font(.platformItemTitle)
                    // For preview to render correctly
                    .foregroundColor(Color(.label))

                Spacer()

                Text(subtitle)
                    .font(.platformItemDesc)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.title)
                .foregroundColor(Color("AccentColor"))
        }
        .card()
    }
}

// MARK: Convenience Inits
extension LinkCard {
    
    init(folder: FavouriteFolderDataModel) {
        self.init(
            thumbnailImage:
                FetchImage(url: folder.thumbnailURL),
            title: folder.title,
            subtitle: "\(folder.mediaCount)个内容"
        )
    }
}

// MARK: Preview
struct FavouriteFolderCell_Previews: PreviewProvider {
    static var previews: some View {
        LinkCard(folder: PlaceHolders.favouriteFolder)
            .padding()
            .frame(width: 375, height: 60)
    }
}
