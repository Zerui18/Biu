//
//  FavouriteOpenFolderModel.swift
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
    func loadFolder(_ folder: FavouriteFolderDataModel) {
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
