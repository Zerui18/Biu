//
//  FavouriteItemCell.swift
//  Biu
//
//  Created by Zerui Chen on 10/7/20.
//

import SwiftUI
import BiliKit
import Nuke

struct FavouriteItemCell: View {
    
    var item: ResourceInfoModel
    
    var body: some View {
        HStack {
            
            // Thumbnail.
            WebImageView(url: item.thumbnailURL)
                .frame(width: 1.6 * 60, height: 60)
                .cornerRadius(5.0)

            Spacer()
                .frame(width: 10)

            // Title & count.
            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.subheadline)

                Spacer()

                Text(item.subheading)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color(.secondarySystemBackground)
                .cornerRadius(20)
        )
    }
}

struct FavouriteItemCell_Previews: PreviewProvider {
    static var previews: some View {
        FavouriteItemCell(item: PlaceHolders.resourceInfo)
            .padding()
            .frame(width: 375, height: 60)
    }
}
