//
//  FavouriteFolderView.swift
//  Biu
//
//  Created by Zerui Chen on 10/7/20.
//

import SwiftUI

struct FavouriteFolderView: View {
    
    @ObservedObject var model: FavouriteOpenFolderModel = .shared
    
    let folder: FavouriteFolderDataModel
    @State var hasLoadedFolder = false
    
    var body: some View {
        Group {
            // Loaded items.
            if let items = model.items {
                ScrollView {
                    ForEach(items) { item in
                        FavouriteItemCell(item: item)
                            .frame(height: 90)
                            .transition(.opacity)
                            .animation(.easeIn)
                            .onTapGesture(count: 1) {
                                MediaPlayerModel.shared.play(item)
                            }
                    }
                    .padding(.bottom, 10)
                    
                    Spacer()
                        .frame(height: 80)
                }
                .padding()
            }
            // Loading / error.
            else {
                LoadingOrErrorView(error: $model.fetchFoldersError)
            }
        }
        .navigationBarTitle(Text(folder.title))
        .onAppear {
            if !hasLoadedFolder {
                model.loadFolder(folder)
            }
            hasLoadedFolder = true
        }
    }
}

struct FavouriteFolderView_Previews: PreviewProvider {
    static var previews: some View {
        FavouriteFolderView(folder: PlaceHolders.favouriteFolder)
    }
}
