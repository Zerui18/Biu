//
//  BKAppEndpoint.swift
//  BiliKit
//
//  Created by Zerui Chen on 11/7/20.
//

import Combine

public enum BKAppEndpoint: String, BKEndpoint {
    
    case getDashMaps = "/x/playurl"
    case getUserSpace = "/x/v2/space"
    
    public var baseURL: URL {
        URL(string: "https://app.bilibili.com")!
    }
    
    // MARK: Publishers
    public static func getDashMaps(forAid aid: Int, cid: Int) -> AnyPublisher<BKResponse<DashMapsResponse>, BKError> {
        let query = [
            "force_host" : "0",
            "fnval" : "16",
            "qn" : "32",
            "npcybs" : "0",
            "cid" : String(cid),
            "fnver" : "0",
            "aid" : String(aid),
        ]
        return BKAppEndpoint.getDashMaps
            .createRequest(using: .get, withQuery: query)
            .fetch()
    }
    
    public static func getUserSpace(forMid mid: Int) -> AnyPublisher<BKResponse<BKUserSpaceResponse>, BKError> {
        let query = [
            "from" : "0",
            "ps" : "10",
            "vmid" : String(mid),
        ]
        return BKAppEndpoint.getUserSpace
            .createRequest(using: .get, withQuery: query)
            .fetch()
    }
}
