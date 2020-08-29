//
//  FavouriteSectionView.swift
//  Biu
//
//  Created by Zerui Chen on 8/7/20.
//

import SwiftUI
import BiliKit

/// Cell that displays a category and the folders it contains.
struct FavouriteSectionView: View {
        
    /// The category this view should display.
    let category: FavouriteCategoryDataModel
    
    var body: some View {
        VStack {
            
            // Heading.
            HStack {
                Text(category.name)
                    .font(.platformItemTitle)
                
                Text(String(category.folders.count))
                    .font(.platformItemDesc)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
                .frame(height: 10)
            
            // Folders List.
            ForEach(category.folders) { folder in
                NavigationLink(destination: FavouriteFolderView(folder: folder)) {
                    VStack {
                        LinkCard(folder: folder)
                            .frame(height: 80)
                        
                        Spacer()
                            .frame(height: 10)
                    }
                }
                .accentColor(.white)
            }
            .frame(maxWidth: .infinity)
            .background(Color.clear)
            .padding([.top, .bottom], 10.p)
        }
    }
}

struct FavouriteCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        FavouriteSectionView(category: PlaceHolders.favouriteCategory)
            .padding()
    }
}
