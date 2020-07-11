//
//  FavouriteModel.swift
//  Biu
//
//  Created by Zerui Chen on 7/7/20.
//

import Combine
import SwiftUI
import BiliKit
import Nuke

/// The model class for favourites.
final class FavouriteModel: ObservableObject {
    
    // MARK: Init
    /// Normal init.
    init() {}
    
    /// Init with pre-existing data, used for debugging.
    init(favouritePage: [FavouriteCategoryModel]) {
        self.favouriteCategories = favouritePage
    }
    
    // MARK: Published
    @Published var favouriteCategories: [FavouriteCategoryModel]!
    
    @Published var fetchCategoriesError: BKError?
    @Published var fetchFoldersError: BKError?

    @Published private(set) var openedFavouriteFolderItems: [ResourceInfoModel]?
    
    // MARK: Private Props
    private var getFavouriteCancellable: AnyCancellable?
    private var getItemsCancellable: AnyCancellable?
    
    // MARK: Methods
    
    /// Start loading the contents of the favourite page.
    func loadFavouritesPage() {
        getFavouriteCancellable =
            // Fetch categories.
            BKMainEndpoint.getFavourite()
            // Map into models.
            .map {
                $0.data.map(FavouriteCategoryModel.create)
            }
            .receive(on: RunLoop.main)
            .sink { (completion) in
                if case .failure(let error) = completion {
                    self.fetchCategoriesError = error
                }
                else {
                    self.fetchCategoriesError = nil
                }
            } receiveValue: { (categoryModels) in
                self.favouriteCategories = categoryModels
            }
    }
    
    /// Start loading the contents of a folder.
    func loadFolder(_ folder: FavouriteFolderModel) {
        getItemsCancellable =
            // Fetch ids.
            BKMainEndpoint.getIds(forFolderWithId: folder.id)
            // Fetch infos for ids.
            .flatMap { idsResponse in
                BKMainEndpoint.getInfos(forResourceIds: idsResponse.data.map({ (id: $0.id, type: $0.type) }))
            }
            // Map into model objects.
            .map {
                $0.data.map(ResourceInfoModel.create)
            }
            .receive(on: RunLoop.main)
            .sink { (completion) in
                if case .failure(let error) = completion {
                    self.fetchFoldersError = error
                }
                else {
                    self.fetchFoldersError = nil
                }
            } receiveValue: { (infoModels) in
                self.openedFavouriteFolderItems = infoModels
            }
    }
    
    /// Reset properties when the user closes a folder.
    func closedFolder() {
        getItemsCancellable?.cancel()
        openedFavouriteFolderItems = nil
        fetchFoldersError = nil
    }
    
}

// MARK: Models
typealias BKFavouriteCategory = BKMainEndpoint.FavouriteCategory

struct FavouriteCategoryModel: Identifiable {

    let id: Int
    let name: String
    let folders: [FavouriteFolderModel]
    
    static func create(with favCategory: BKFavouriteCategory) -> FavouriteCategoryModel {
        FavouriteCategoryModel(id: favCategory.id,
                               name: favCategory.name,
                               folders: favCategory.folders.map(FavouriteFolderModel.create))
    }
    
}

typealias BKFavouriteFolder = BKMainEndpoint.FavouriteCategory.MediaListResponse.Folder

struct FavouriteFolderModel: Identifiable {
    
    let id: Int
    let title: String
    let mediaCount: Int
    let thumbnailURL: URL
    
    static func create(with favFolder: BKFavouriteFolder) -> FavouriteFolderModel {
        FavouriteFolderModel(id: favFolder.id,
                             title: favFolder.title,
                             mediaCount: favFolder.mediaCount,
                             thumbnailURL: favFolder.thumbnailURL)
    }
}


typealias BKResourceInfo = BKMainEndpoint.ResourceInfo

struct ResourceInfoModel: Identifiable {

    let id: Int
    let bvid: String
    let title: String
    let thumbnailURL: URL
    let pageCount: Int
    let duration: Int
    
    var formattedDuration: String {
        duration.formattedDuration()
    }
    
    var subheading: String {
        pageCount > 1 ? "\(pageCount)p" : formattedDuration
    }
    
    static func create(with resourceInfo: BKResourceInfo) -> ResourceInfoModel {
        ResourceInfoModel(id: resourceInfo.id,
                          bvid: resourceInfo.bvid,
                          title: resourceInfo.title,
                          thumbnailURL: resourceInfo.thumbnailURL,
                          pageCount: resourceInfo.pageCount,
                          duration: resourceInfo.duration)
    }
    
}

// MARK: Int + Format
fileprivate extension Int {
    func formattedDuration() -> String {
        let (hours, remainder) = self.quotientAndRemainder(dividingBy: 3600)
        let (minutes, seconds) = remainder.quotientAndRemainder(dividingBy: 60)
        if hours > 0 {
            return "\(hours)h \(minutes):\(seconds)"
        }
        else {
            return "\(minutes):\(seconds)"
        }
    }
}
