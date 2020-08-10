//
//  SavedUpper.swift
//  Biu
//
//  Created by Zerui Chen on 5/8/20.
//

import Foundation
import BiliKit

extension SavedUpper {
    
    convenience init(upperInfo: BKMainEndpoint.VideoInfoResponse.Upper) {
        self.init(context: AppDelegate.shared.persistentContainer.viewContext)
        self.name = upperInfo.name
        self.mid = Int64(upperInfo.mid)
        self.thumbnailURL = upperInfo.face
    }
    
}
