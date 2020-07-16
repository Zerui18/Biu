//
//  FavouriteFolderView.swift
//  Biu
//
//  Created by Zerui Chen on 10/7/20.
//

import SwiftUI

struct FavouriteFolderView: View {
    
    @ObservedObject var model: FavouriteModel = .shared
    
    let folder: FavouriteFolderModel
    @State var hasLoadedFolder = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                // Loaded items.
                if let items = model.openedFavouriteFolderItems {
                    VStack {
                        ForEach(items) { item in
                            FavouriteItemCell(item: item)
                                .frame(height: 90)
                                .transition(.opacity)
                                .animation(.easeIn)
                                .onTapGesture(count: 1) {
                                    MediaPlayerModel.shared.play(item)
                                }
//                                .onTapGesture(count: 2) {
//                                    mediaPlayerModel.play(item)
//                                }
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
