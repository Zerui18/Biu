//
//  FavouriteFolderModel.swift
//  Biu
//
//  Created by Zerui Chen on 28/7/20.
//

import Combine
import BiliKit
import Tetra

class FavouriteOpenFolderModel: ObservableObject {
    
    static let shared = FavouriteOpenFolderModel()
    
    init(items: [ResourceInfoModel]? = nil) {
        self.items = items
    }
    
    @Published var fetchFoldersError: BKError?
    @Published private(set) var items: [ResourceInfoModel]?
    
    private var getItemsCancellable: AnyCancellable?
    
    /// Start loading the contents of a folder.
    func loadFolder(_ folder: FavouriteFolderModel) {
        // Clean up if opened new folder.
        closedFolder()
        // Fetch items.
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
                self.items = infoModels
            }
    }
    
    /// Reset properties when the user closes a folder.
    func closedFolder() {
        getItemsCancellable?.cancel()
        items = nil
        fetchFoldersError = nil
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

/// Class that represents a single media item.
class ResourceInfoModel: Identifiable, ObservableObject {

    let id = UUID()
    
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
    
    var downloadTask: TTask!
    
    var localURL: URL {
        DownloadsModel.shared.downloadsFolder.appendingPathComponent("\(bvid).mp4")
    }
    
    init(bvid: String, title: String, thumbnailURL: URL, pageCount: Int, duration: Int) {
        self.bvid = bvid
        self.title = title
        self.thumbnailURL = thumbnailURL
        self.pageCount = pageCount
        self.duration = duration
        self.downloadTask = Tetra.shared.downloadTask(forId: bvid, dstURL: localURL)
    }
    
    static func create(with resourceInfo: BKResourceInfo) -> ResourceInfoModel {
        ResourceInfoModel(bvid: resourceInfo.bvid,
                          title: resourceInfo.title,
                          thumbnailURL: resourceInfo.thumbnailURL,
                          pageCount: resourceInfo.pageCount,
                          duration: resourceInfo.duration)
    }
    
}
