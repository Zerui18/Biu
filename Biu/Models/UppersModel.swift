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
    /// The SavedUpper copy of the currently displayed upper.
    @Published var savedUpper: SavedUpper?
    /// The remotely-loaded data of the currently displayed upper.
    @Published var remoteUpper: BKAppEndpoint.BKUserSpaceResponse?
    /// Error when loading remoteUpper.
    @Published var error: Error?
    
    // MARK: Cancellables
    private var loadUpperCancellable: AnyCancellable?
    
    /// Try to find a SavedUpper by id.
    private func savedUpper(forMid mid: Int) -> SavedUpper? {
        self.savedUppers.first(where: { $0.mid == mid })
    }
    
    /// Convert an array of `Upper` objects from Bilikit to an array of `SavedUpper`, creating new ones if necessary.
    func savedUppers(from uppers: [MediaInfoDataModel.Upper]) -> [SavedUpper] {
        var savedUppers = [SavedUpper]()
        for upper in uppers {
            // Try to find existing SavedUpper.
            if let savedUpper = self.savedUpper(forMid: upper.mid) {
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
    func loadUpper(with upper: UpperRepresentable) {
        self.savedUpper = nil
        self.remoteUpper = nil
        self.error = nil
        
        if let saved = upper as? SavedUpper {
            self.savedUpper = saved
        }
        
        loadUpperCancellable =
            BKAppEndpoint.getUserSpace(forMid: upper.getMid())
            .receive(on: RunLoop.main)
            .sink { (completion) in
                if case let .failure(error) = completion {
                    self.error = error
                }
                else {
                    self.error = nil
                }
            } receiveValue: { response in
                self.remoteUpper = response.data
                self.savedUpper?.update(with: response.data)
            }
    }
    
}

extension BKAppEndpoint.BKUserSpaceResponse.Media: Identifiable {
    public var id: String {
        bvid
    }
}
