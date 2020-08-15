//
//  FavouriteCategoryDataModel.swift
//  Biu
//
//  Created by Zerui Chen on 14/8/20.
//

import BiliKit

typealias BKFavouriteCategory = BKMainEndpoint.FavouriteCategory

struct FavouriteCategoryDataModel: Identifiable {

    let id: Int
    let name: String
    let folders: [FavouriteFolderModel]
    
    static func create(with favCategory: BKFavouriteCategory) -> FavouriteCategoryDataModel {
        FavouriteCategoryDataModel(id: favCategory.id,
                               name: favCategory.name,
                               folders: favCategory.folders.map(FavouriteFolderModel.create))
    }
    
}
