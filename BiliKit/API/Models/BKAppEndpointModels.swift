//
//  BKAppEndpointModels.swift
//  BiliKit
//
//  Created by Zerui Chen on 11/7/20.
//

import Foundation

extension BKAppEndpoint {
    // MARK: Dash Map
    public struct DashMapsResponse: Codable {
        public let dash: DashMaps
        
        public struct DashMaps: Codable {
            public let video: [DashItem]
            public let audio: [DashItem]
            
            public struct DashItem: Codable {
                public let id: Int
                public let url: URL
                public let bandwidth: Int
                public let size: Int
                
                public enum CodingKeys: String, CodingKey {
                    case id, url = "base_url", bandwidth, size
                }
            }
        }
    }
}
