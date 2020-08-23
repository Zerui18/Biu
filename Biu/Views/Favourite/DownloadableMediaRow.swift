//
//  DownloadableMediaRow.swift
//  Biu
//
//  Created by Zerui Chen on 10/7/20.
//

import SwiftUI
import BiliKit
import Tetra

struct DownloadableMediaRow: View {
    
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
                .frame(width: Sizes.itemImage.width, height: Sizes.itemImage.height)
                .cornerRadius(7.p)

            Spacer()
                .frame(width: 10.p)

            // Title & duration/count & downloaded.
            VStack(alignment: .leading) {
                Text(item.getCleanedTitle())
                    .font(.platformItemTitle)
                    .lineLimit(2)
                    .layoutPriority(1)

                Spacer()

                HStack(alignment: .bottom) {
                    Text(item.subheading)
                        .font(.platformItemDesc)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    // Downloaded check.
                    Group {
                        switch downloadState.value {
                        case .none:
                            // Download button.
                            Button {
                                DownloadsModel.shared.initiateDownload(forMedia: item)
                            } label:  {
                                Image(systemName: "square.and.arrow.down")
                            }
                            .padding([.bottom, .trailing], 3.p)
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
                    .font(.system(size: 17.p))
                    .foregroundColor(.accentColor)
                    .padding([.bottom, .trailing], 3.p)
                    .transition(AnyTransition.opacity.animation(.linear))
                }
            }
        }
        .card()
    }
}

struct FavouriteItemCell_Previews: PreviewProvider {
    static var previews: some View {
        DownloadableMediaRow(item: PlaceHolders.resourceInfo)
            .padding()
            .frame(height: 80)
    }
}
