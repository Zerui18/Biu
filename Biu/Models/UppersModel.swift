//
//  UppersModel.swift
//  Biu
//
//  Created by Zerui Chen on 12/8/20.
//

import CoreData
import BiliKit
import Combine

class UppersModel: ObservableObject {
    
    static let shared = UppersModel()
    
    private init() {
        // Fetch all SavedUppers.
        savedUppers = try! mocGlobal.fetch(SavedUpper.fetchRequest())
    }
    
    /// Unordered SavedUpper objects.
    private var savedUppers: [SavedUpper]
    
    // MARK: Published
    @Published var currentUpper: UpperRepresentable?
    @Published var error: Error?
    
    // MARK: Cancellables
    private var loadUpperCancellable: AnyCancellable?
    
    /// Convert an array of `Upper` objects from Bilikit to an array of `SavedUpper`, creating new ones if necessary.
    func savedUppers(from uppers: [MediaInfoDataModel.Upper]) -> [SavedUpper] {
        var savedUppers = [SavedUpper]()
        for upper in uppers {
            // Try to find existing SavedUpper.
            if let savedUpper = self.savedUppers.first(where: { $0.mid == upper.mid }) {
                savedUppers.append(savedUpper)
                continue
            }
            // Not found, create new SavedUpper.
            let savedUpper = SavedUpper(context: mocGlobal)
            savedUpper.name = upper.name
            savedUpper.mid = Int64(upper.mid)
            savedUpper.face = upper.face
            savedUppers.append(savedUpper)
            // Append to self.savedUppers.
            self.savedUppers.append(savedUpper)
        }
        return savedUppers
    }
    
    /// Start loading information for a given upper `mid`,
    func loadUpper(forMid mid: Int, updating savedUpper: SavedUpper? = nil) {
        loadUpperCancellable =
            BKAppEndpoint.getUserSpace(forMid: mid)
            .receive(on: RunLoop.main)
            .sink { (completion) in
                if case let .failure(error) = completion {
                    self.error = error
                }
                else {
                    self.error = nil
                }
            } receiveValue: { response in
                self.currentUpper = response.data
            }
    }
    
}
