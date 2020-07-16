//
//  BKMainEndpoint.swift
//  BiliKit
//
//  Created by Zerui Chen on 7/7/20.
//

import Foundation
import Combine

/// The authentication endpoint.
public enum BKMainEndpoint: String, BKEndpoint {
    
    // MARK: Endpoints
    case getFavourite = "/x/v3/fav/folder/space"
    case getIds = "/x/v3/fav/resource/ids"
    case getInfos = "/x/v3/fav/resource/infos"
    case getVideoInfo = "/x/web-interface/view"
    
    public var baseURL: URL {
        URL(string: "https://api.bilibili.com")!
    }
    
    public struct Page {
        public init(pageNumber: Int, pageSize: Int) {
            self.pageNumber = pageNumber
            self.pageSize = pageSize
        }
        
        public let pageNumber: Int
        public let pageSize: Int
        
        public var nextPage: Page {
            Page(pageNumber: pageNumber + 1, pageSize: pageSize)
        }
    }
    
    // MARK: Publishers
    public static func getFavourite() -> AnyPublisher<BKResponse<FavouritePageResponse>, BKError> {
        BKClient.shared
            .fromUserInfo { passport in
                let query = [
                    "access_key" : passport.accessToken,
                    "up_mid" : String(passport.mid),
                ]
                return BKMainEndpoint.getFavourite
                    .createRequest(using: .get, withQuery: query)
                    .fetch()
            }
    }
    
    public static func getIds(forFolderWithId id: Int) -> AnyPublisher<BKResponse<ResourceIdsResponse>, BKError> {
        BKClient.shared
            .fromUserInfo { passport in
                let query = [
                    "access_key" : passport.accessToken,
                    "mid" : String(passport.mid),
                    "media_id" : String(id),
                    "pn" : "1",
                ]
                return BKMainEndpoint.getIds
                    .createRequest(using: .get, withQuery: query)
                    .fetch()
            }
    }
    
    public static func getInfos(forResourceIds ids: [(id: Int, type: Int)]) -> AnyPublisher<BKResponse<ResourceInfosResponse>, BKError> {
        BKClient.shared
            .fromUserInfo { passport in
                let resources = ids
                    .map({ "\($0.id):\($0.type)" })
                    .joined(separator: ",")
                let query = [
                    "access_key" : passport.accessToken,
                    "mid" : String(passport.mid),
                    "resources" : resources,
                ]
                return BKMainEndpoint.getInfos
                    .createRequest(using: .get, withQuery: query)
                    .fetch()
            }
    }
    
    public static func getVideoInfo(forBV bv: String) -> AnyPublisher<BKResponse<VideoInfoResponse>, BKError> {
        let query = [
            "bvid" : bv
        ]
        return BKMainEndpoint.getVideoInfo
            .createRequest(using: .get, withQuery: query)
            .fetch()
    }
}
