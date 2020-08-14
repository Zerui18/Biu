//
//  SavedUpper.swift
//  Biu
//
//  Created by Zerui Chen on 5/8/20.
//

import CoreData
import BiliKit

@objc(SavedUpper)
public class SavedUpper: NSManagedObject {
    
    lazy var latinName = self.name!.toLatin()
    
    convenience init(upperInfo: BKMainEndpoint.VideoInfoResponse.Upper) {
        self.init(context: AppDelegate.shared.persistentContainer.viewContext)
        self.name = upperInfo.name
        self.mid = Int64(upperInfo.mid)
        self.face = upperInfo.face
    }
    
}

extension Sequence where Iterator.Element == SavedUpper {
    /// Group the uppers by the first letter of their latin names and sort the groups.
    func groupedAndSorted() -> [(Character, [SavedUpper])] {
        // Group.
        let groups = Dictionary(grouping: self, by: \SavedUpper.latinName.first.unsafelyUnwrapped)
        // Sort.
        return groups.mapValues { uppers in
            uppers.sorted(by: { $0.latinName < $1.latinName })
        }.map { ($0, $1) }.sorted(by: { $0.0 < $1.0 })
    }
}

extension SavedUpper: UpperRepresentable {
    func getMid() -> Int {
        Int(mid)
    }
    
    func getName() -> String {
        name!
    }
    
    func getFace() -> URL {
        face!
    }
    
    func getBanner() -> URL? {
        banner
    }
    
    func getBannerNight() -> URL? {
        bannerNight
    }
    
    func getSign() -> String? {
        sign
    }
}
