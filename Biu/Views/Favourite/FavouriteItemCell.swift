//
//  FavouriteItemCell.swift
//  Biu
//
//  Created by Zerui Chen on 10/7/20.
//

import SwiftUI
import Nuke
import BiliKit

struct FavouriteItemCell: View {
    
    init(item: ResourceInfoModel) {
        self.item = item
        self.thumbnailImage = FetchImage(placeholder: UIImage(named: "bg_placeholder")!,
                                         url: item.thumbnailURL)
    }
    
    @EnvironmentObject var model: FavouriteModel
    @EnvironmentObject var downloadsModel: DownloadsModel
    
    @ObservedObject var thumbnailImage: FetchImage
    
    /// The resource displayed by this cell.
    var item: ResourceInfoModel
    
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
                Text(item.title)
                    .font(.subheadline)
                    .lineLimit(2)
                    .layoutPriority(1)

                Spacer()

                HStack(alignment: .bottom) {
                    Text(item.subheading)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    // Downloaded check.
                    if downloadsModel.isDownloaded(resource: item) {
                        Image(systemName: "checkmark")
                            .font(.body)
                            .foregroundColor(.accentColor)
                    }
                    // Or download button.
                    else {
                        Button {
                            downloadsModel.initiateDownload(forResource: item)
                        } label:  {
                            Image(systemName: "square.and.arrow.down.on.square")
                                .font(.body)
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color(.secondarySystemBackground)
                .cornerRadius(10)
        )
    }
}

struct FavouriteItemCell_Previews: PreviewProvider {
    static var previews: some View {
        FavouriteItemCell(item: PlaceHolders.resourceInfo)
            .environmentObject(PlaceHolders.favouritePage)
            .environmentObject(DownloadsModel())
            .padding()
            .frame(height: 80)
    }
}
