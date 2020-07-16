//
//  FavouriteView.swift
//  Biu
//
//  Created by Zerui Chen on 7/7/20.
//

import SwiftUI

/// Root view for favourites that displays a list of categories.
struct FavouriteView: View {
    
    @ObservedObject var model: FavouriteModel = .shared
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    // Loaded favourite page.
                    if let categories = model.favouriteCategories {
                        VStack {
                            ForEach(categories) { category in
                                FavouriteCategoryCell(category: category)
                            }
                            .padding(.bottom, 10)
                            
                            Spacer()
                                .frame(height: 80)
                        }
                        .padding()
                    }
                    // Loading / error.
                    else {
                        VStack(spacing: 10) {
                            // Error.
                            if let error = model.fetchCategoriesError {
                                Text(error.title)
                                    .font(.headline)
                                if let message = error.message {
                                    Text(message)
                                        .font(.subheadline)
                                }
                            }
                            // Loading.
                            else {
                                Text("Loading")
                            }
                        }
                        .frame(minWidth: geometry.size.width,
                               minHeight: geometry.size.height)
                    }
                }
                .frame(height: geometry.size.height)
            }
            .navigationBarTitle(Text("收藏"))
        }
        .onAppear {
            if model.favouriteCategories == nil {
                model.loadFavouritesPage()
            }
        }
    }
}

struct FavouritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavouriteView()
    }
}
