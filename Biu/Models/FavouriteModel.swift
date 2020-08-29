//
//  FavouriteModel.swift
//  Biu
//
//  Created by Zerui Chen on 7/7/20.
//

import Combine
import BiliKit

/// The model class for favourites.
final class FavouriteModel: ObservableObject {
    
    static let shared = FavouriteModel()
    
    // MARK: Init
    /// Normal init.
    init() {}
    
    /// Init with pre-existing data, used for debugging.
    init(favouritePage: [FavouriteCategoryDataModel]) {
        self.favouriteCategories = favouritePage
    }
    
    // MARK: Published
    @Published var favouriteCategories: [FavouriteCategoryDataModel]!
    
    @Published var fetchCategoriesError: BKError?
    
    // MARK: Private Props
    private let favouritesPublisher =
        BKMainEndpoint.getFavourite()
        // Map into models.
        .map {
            $0.data.map(FavouriteCategoryDataModel.create)
        }
        .receive(on: RunLoop.main)
    private var favouritesCancellable: AnyCancellable?
    // MARK: Methods
    
    /// Start loading the contents of the favourite page.
    func loadFavouritesPage() {
        favouritesCancellable = favouritesPublisher
            .sink { (completion) in
                if case .failure(let error) = completion {
                    self.fetchCategoriesError = error
                }
                else {
                    self.fetchCategoriesError = nil
                }
            } receiveValue: { (categoryModels) in
                self.favouriteCategories = categoryModels.filter { !$0.folders.isEmpty }
            }
    }
    
}
