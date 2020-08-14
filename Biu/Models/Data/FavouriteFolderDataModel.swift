//
//  FavouriteFolderDataModel.swift
//  Biu
//
//  Created by Zerui Chen on 14/8/20.
//

import BiliKit

typealias BKFavouriteFolder = BKMainEndpoint.FavouriteCategory.MediaListResponse.Folder

struct FavouriteFolderDataModel: Identifiable {
    
    let id: Int
    let title: String
    let mediaCount: Int
    let thumbnailURL: URL
    
    static func create(with favFolder: BKFavouriteFolder) -> FavouriteFolderDataModel {
        FavouriteFolderDataModel(id: favFolder.id,
                             title: favFolder.title,
                             mediaCount: favFolder.mediaCount,
                             thumbnailURL: favFolder.thumbnailURL)
    }
}
