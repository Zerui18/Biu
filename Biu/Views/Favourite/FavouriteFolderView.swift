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
                    Color.clear
                        .frame(height: 10)
                    
                    ForEach(items) { item in
                        DownloadableMediaRow(item: item)
                            .frame(height: 90.p)
                            .makeInteractive(media: item)
                    }
                    .padding([.leading, .trailing, .bottom])
                    
                    Color.clear
                        .frame(height: 90)
                }
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
