//
//  MediaRepresentable.swift
//  Biu
//
//  Created by Zerui Chen on 14/8/20.
//

import Foundation
import BiliKit
import Tetra

/// Objects which can be used to display a media.
protocol MediaRepresentable {
    func getBVId() -> String
    func getTitle() -> String
    func getCleanedTitle() -> String
    func getThumbnailURL() -> URL
    func getAuthor() -> UpperRepresentable
    func getLocalURL() -> URL
    func getDownloadTask() -> TTask
}

extension MediaRepresentable {
    /// The default implementation.
    func getCleanedTitle() -> String {
        getTitle()
            .cleanedTitle()
    }
    
    /// The default implementation, should not be overriden.
    func getLocalURL() -> URL {
        DownloadsModel.localURL(forMedia: self)
    }
    
    /// The default implementation, should not be overriden.
    func getDownloadTask() -> TTask {
        return Tetra.shared.downloadTask(forId: getBVId(), dstURL: getLocalURL())
    }
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
