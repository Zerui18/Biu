//
//  FavouriteCategoryCell.swift
//  Biu
//
//  Created by Zerui Chen on 8/7/20.
//

import SwiftUI
import BiliKit

/// Cell that displays a category and the folders it contains.
struct FavouriteCategoryCell: View {
        
    /// The category this view should display.
    let category: FavouriteCategoryModel
    
    var body: some View {
        VStack {
            
            // Heading.
            HStack {
                Text(category.name)
                    .font(.headline)
                
                Text(String(category.folders.count))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
                .frame(height: 10)
            
            // Folders List.
            ForEach(category.folders) { folder in
                NavigationLink(destination: FavouriteFolderView(folder: folder)) {
                    VStack {
                        FavouriteFolderCell(folder: folder)
                            .transition(.slide)
                        
                        Spacer()
                            .frame(height: 10)
                    }
                }
                .accentColor(.white)
            }
            .frame(maxWidth: .infinity)
            .background(Color.clear)
        }
    }
}

struct FavouriteCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        FavouriteCategoryCell(category: PlaceHolders.favouriteCategory)
            .padding()
            .frame(maxWidth: 375, maxHeight: .infinity)
    }
}
