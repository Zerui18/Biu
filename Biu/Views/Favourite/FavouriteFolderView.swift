//
//  FavouriteFolderView.swift
//  Biu
//
//  Created by Zerui Chen on 10/7/20.
//

import SwiftUI

struct FavouriteFolderView: View {
    
    @EnvironmentObject var model: FavouriteModel
    var folder: FavouriteFolderModel
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                // Loaded items.
                if let items = model.openedFavouriteFolderItems {
                    VStack {
                        ForEach(items) { item in
                            FavouriteItemCell(item: item)
                                .transition(.opacity)
                                .animation(.easeIn)
                            
                            Spacer()
                                .frame(height: 20)
                        }
                    }
                    .padding()
                }
                // Loading / error.
                else {
                    VStack(alignment: .leading, spacing: 10) {
                        // Error.
                        if let error = model.fetchFoldersError {
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
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            .frame(maxHeight: geometry.size.height)
        }
        .navigationBarTitle(Text(folder.title))
        .onAppear {
            model.loadFolder(folder)
        }
        .onDisappear(perform: model.closedFolder)
    }
}

struct FavouriteFolderView_Previews: PreviewProvider {
    static var previews: some View {
        FavouriteFolderView(folder: PlaceHolders.favouriteFolder)
            .environmentObject(PlaceHolders.favouritePage)
    }
}
