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
    
    @EnvironmentObject var model: FavouriteModel
    
    /// The category this view should display.
    var category: FavouriteCategoryModel = PlaceHolders.favouriteCategory
    
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
                .frame(height: 20)
            
            // Folders List.
            ForEach(category.folders) { folder in
                NavigationLink(destination: FavouriteFolderView(folder: folder)) {
                    VStack {
                        FavouriteFolderCell(folder: folder)
                            .transition(.slide)
                        
                        Spacer()
                            .frame(height: 20)
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
            .environmentObject(FavouriteModel())
            .padding()
            .frame(maxWidth: 375, maxHeight: .infinity)
    }
}