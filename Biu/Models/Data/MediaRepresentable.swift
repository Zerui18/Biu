//
//  MediaRepresentable.swift
//  Biu
//
//  Created by Zerui Chen on 14/8/20.
//

import Foundation
import BiliKit

/// Objects which can be used to display a media.
protocol MediaRepresentable {
    func getBVId() -> String
    func getTitle() -> String
    func getThumbnailURL() -> URL
    func getAuthor() -> UpperRepresentable
}

extension BKAppEndpoint.BKUserSpaceResponse.Media: MediaRepresentable {
    func getBVId() -> String {
        bvid
    }
    
    func getTitle() -> String {
        title
    }
    
    func getThumbnailURL() -> URL {
        cover
    }
    
    func getAuthor() -> UpperRepresentable {
        fatalError("getAuthor() is not implemented for BKAppEndpoint.BKUserSpaceResponse.Media")
    }
}
