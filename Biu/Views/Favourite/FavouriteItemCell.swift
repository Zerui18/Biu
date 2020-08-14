//
//  FavouriteItemCell.swift
//  Biu
//
//  Created by Zerui Chen on 10/7/20.
//

import SwiftUI
import BiliKit
import Tetra

struct FavouriteItemCell: View {
    
    init(item: ResourceInfoModel) {
        self.item = item
        self.thumbnailImage = FetchImage(url: item.thumbnailURL)
        self.downloadState = item.downloadTask.simpleState
    }
        
    @ObservedObject var downloadState: TTask.SimpleState
    @ObservedObject var thumbnailImage: FetchImage
    
    @State var isAnimatingRotation = false
    
    /// The resource displayed by this cell.
    var item: ResourceInfoModel
    
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
                    Group {
                        switch downloadState.value {
                        case .none:
                            // Download button.
                            Button {
                                DownloadsModel.shared.initiateDownload(forResource: item)
                            } label:  {
                                Image(systemName: "square.and.arrow.down")
                            }
                            .padding([.bottom, .trailing], 3)
                        case .downloading:
                            // Rotating icon.
                            Image(systemName: "arrow.2.circlepath.circle")
                                .rotationEffect(Angle(radians: isAnimatingRotation ? .pi*2:0), anchor: .center)
                                .animation(
                                    Animation.linear
                                        .repeatForever(autoreverses: false)
                                        .speed(0.1)
                                )
                                .onAppear {
                                    isAnimatingRotation = true
                                }
                                .onDisappear {
                                    isAnimatingRotation = false
                                }
                        case .downloaded:
                            // Gray tick.
                            Image(systemName: "checkmark")
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(width: 25, height: 20)
                    .font(.body)
                    .foregroundColor(.accentColor)
                    .padding([.bottom, .trailing], 3)
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
            .padding()
            .frame(height: 80)
    }
}
