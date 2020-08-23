//
//  ResourceInfoDataModel.swift
//  Biu
//
//  Created by Zerui Chen on 14/8/20.
//

import BiliKit
import Tetra

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
    
    init(bvid: String, title: String, thumbnailURL: URL, pageCount: Int, duration: Int) {
        self.bvid = bvid
        self.title = title
        self.thumbnailURL = thumbnailURL
        self.pageCount = pageCount
        self.duration = duration
        self.downloadTask = getDownloadTask()
    }
    
    static func create(with resourceInfo: BKResourceInfo) -> ResourceInfoModel {
        ResourceInfoModel(bvid: resourceInfo.bvid,
                          title: resourceInfo.title,
                          thumbnailURL: resourceInfo.thumbnailURL,
                          pageCount: resourceInfo.pageCount,
                          duration: resourceInfo.duration)
    }
    
}

extension ResourceInfoModel: MediaRepresentable {
    func getBVId() -> String {
        bvid
    }
    
    func getTitle() -> String {
        title
    }
    
    func getThumbnailURL() -> URL {
        thumbnailURL
    }
    
    func getAuthor() -> UpperRepresentable {
        fatalError("ResourceInfoModel.getAuthor is not implemented!")
    }
}
