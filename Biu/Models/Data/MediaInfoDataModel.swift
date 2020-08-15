//
//  MediaInfoDataModel.swift
//  Biu
//
//  Created by Zerui Chen on 14/8/20.
//

import BiliKit
import AVFoundation

// MARK: Media Info Model
struct MediaInfoDataModel {
    
    let aid: Int
    let bvid: String
    let cid: Int
    let title: String
    let desc: String
    let duration: Int
    let mediaURL: URL
    let thumbnailURL: URL
    
    /// This property is nil when the instance is created from a `SavedMedia` object.
    let staff: [Upper]?
    /// This property is nil when the instance is created from a `SavedMedia` object.
    let owner: Upper?
    
    struct Upper {
        let name: String
        let mid: Int
        let face: URL
        let title: String?
        
        init(with upper: BKMainEndpoint.VideoInfoResponse.Upper) {
            self.name = upper.name
            self.mid = upper.mid
            self.face = upper.face
            self.title = upper.title
        }
        
        init(with upper: SavedUpper) {
            self.name = upper.name!
            self.mid = Int(upper.mid)
            self.face = upper.face!
            self.title = nil
        }
    }
    
    /// Flag indicating whether this object is created from a SavedMedia object, in which case mediaURL would contain a local URL.
    let isSavedMedia: Bool
    
    let player: AVPlayer
    
    init(with videoInfo: BKMainEndpoint.VideoInfoResponse, mediaURL: URL) {
        self.aid = videoInfo.aid
        self.bvid = videoInfo.bvid
        self.cid = videoInfo.pages[0].cid
        self.title = videoInfo.title
        self.desc = videoInfo.desc
        self.duration = videoInfo.duration
        self.mediaURL = mediaURL
        self.thumbnailURL = videoInfo.thumbnailURL
        self.isSavedMedia = false
        self.player = AVPlayer(url: mediaURL)
        self.staff = videoInfo.staff?.map(Upper.init)
        self.owner = .init(with: videoInfo.owner)
    }
    
    init(with savedMedia: SavedMedia) {
        self.aid = Int(savedMedia.aid)
        self.bvid = savedMedia.bvid!
        self.cid = Int(savedMedia.cid)
        self.title = savedMedia.title!
        self.desc = savedMedia.desc!
        self.duration = Int(savedMedia.duration)
        self.mediaURL = savedMedia.localURL
        self.thumbnailURL = savedMedia.thumbnailURL!
        self.isSavedMedia = true
        self.player = AVPlayer(url: savedMedia.localURL)
        self.staff = nil
        self.owner = .init(with: savedMedia.owner!)
    }
}

extension MediaInfoDataModel.Upper: UpperRepresentable {
    func getMid() -> Int {
        mid
    }
    
    func getName() -> String {
        name
    }
    
    func getFace() -> URL {
        face
    }
    
    func getBanner() -> URL? {
        nil
    }
    
    func getBannerNight() -> URL? {
        nil
    }
    
    func getSign() -> String? {
        nil
    }
}

extension MediaInfoDataModel: MediaRepresentable {
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
        owner!
    }
}
