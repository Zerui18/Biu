//
//  FavouriteCategoryView.swift
//  Biu
//
//  Created by Zerui Chen on 8/7/20.
//

import SwiftUI
import BiliKit

/// View that displays a main folder, with a list displaying its subfolders.
struct FavouriteCategoryCell: View {
    
    @EnvironmentObject var model: FavouriteViewModel
    
    /// The category this view should display.
    var category: FavouriteCategoryModel = PlaceHolders.favouriteCategory
    
    var body: some View {
        VStack {
            HStack {
                Text(category.name)
                    .font(.headline)
                
                Text(String(category.folders.count))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(category.folders) { folder in
                NavigationLink(destination: Text(folder.title)) {
                    FavouriteFolderCell(folder: folder)
                        .frame(maxWidth: 375, maxHeight: 60)
                        .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 0))
                }
                .accentColor(.white)
                Divider()
            }
            .frame(maxWidth: .infinity)
            .background(Color.clear)
        }
        .padding()
    }
}

struct FavouriteCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        FavouriteCategoryCell(category: PlaceHolders.favouriteCategory)
            .environmentObject(FavouriteViewModel())
            .frame(maxWidth: 375, maxHeight: .infinity)
    }
}
