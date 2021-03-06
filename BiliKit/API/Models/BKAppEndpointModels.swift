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
    // MARK: User Space
    public struct BKUserSpaceResponse: Codable {
        public let card: Card
        public let images: Images
        public let archive: Archive
        
        public struct Card: Codable {
            public let mid: String
            public let name: String
            public let sex: String
            public let face: URL
            public let sign: String
        }
        
        public struct Images: Codable {
            public let banner: URL
            public let _bannerNight: String
            
            public var bannerNight: URL? {
                URL(string: _bannerNight)
            }
            
            public enum CodingKeys: String, CodingKey {
                case banner = "imgUrl", _bannerNight = "night_imgurl"
            }
        }
        
        public struct Archive: Codable {
            public let count: Int
            public let item: [Media]
        }
        
        public struct Media: Codable {
            public let title: String
            public let cover: URL
            public let duration: Int
            public let bvid: String
        }
    }
}
