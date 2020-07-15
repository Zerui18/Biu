//
//  BKMainEndpoint.swift
//  BiliKit
//
//  Created by Zerui Chen on 7/7/20.
//

import Foundation

extension BKMainEndpoint {
    
    // MARK: Favourite Page
    public typealias FavouritePageResponse = [FavouriteCategory]
    
    public struct FavouriteCategory: Codable {
        public let id: Int
        public let foldersList: MediaListResponse
        public let name: String
        
        public enum CodingKeys: String, CodingKey {
            case id, foldersList = "mediaListResponse", name
        }
        
        /// Convenient accessor for folders.
        public var folders: [MediaListResponse.Folder] {
            foldersList.folders ?? []
        }
        
        public struct MediaListResponse: Codable {
            public let count: Int
            public let folders: [Folder]?
            
            public enum CodingKeys: String, CodingKey {
                case count, folders = "list"
            }
            
            public struct Folder: Codable {
                public let thumbnailURL: URL
                public let fid: Int
                public let mid: Int
                public let id: Int
                public let mediaCount: Int
                public let title: String
                
                public enum CodingKeys: String, CodingKey {
                    case thumbnailURL = "cover", fid, mid, id, mediaCount = "media_count", title
                }
            }
        }
    }
    
    // MARK: Resource Ids
    public typealias ResourceIdsResponse = [ResourceId]
    public struct ResourceId: Codable {
        public let bvid: String
        public let id: Int
        public let type: Int
    }
    
    // MARK: Resource Infos
    public typealias ResourceInfosResponse = [ResourceInfo]
    public struct ResourceInfo: Codable {
        public let bvid: String
        public let thumbnailURL: URL
        public let duration: Int
        public let id: Int
        public let intro: String
        public let pageCount: Int
        public let title: String
        public let type: Int
        
        public enum CodingKeys: String, CodingKey {
            case bvid, thumbnailURL = "cover", duration, id, intro, pageCount = "page", title, type
        }
    }
    
    // MARK: Video Info
    public struct VideoInfoResponse: Codable {
        public let aid: Int
        public let bvid: String
        public let title: String
        public let desc: String
        public let duration: Int
        public let thumbnailURL: URL
        public let pages: [Page]

        public enum CodingKeys: String, CodingKey {
            case aid, bvid, title, desc, duration, thumbnailURL = "pic", pages
        }
        
        public struct Page: Codable {
            public let cid: Int
        }
    }
}
