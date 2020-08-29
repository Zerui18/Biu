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
            Group {
                // Loaded favourite page.
                if let categories = model.favouriteCategories {
                    ScrollView {
                        ForEach(categories) { category in
                            FavouriteSectionView(category: category)
                        }
                        .padding(.bottom, 10.p)
                        
                        Spacer()
                            .frame(height: 80)
                    }
                    .padding([.leading, .trailing])
                }
                // Loading / error.
                else {
                    LoadingOrErrorView(error: $model.fetchCategoriesError)
                }
            }
            .frame(maxHeight: .infinity)
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
        FavouriteView(model: PlaceHolders.favouritePage)
    }
}
