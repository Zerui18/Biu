//
//  UpperRepresentable.swift
//  Biu
//
//  Created by Zerui Chen on 14/8/20.
//

import BiliKit

/// Objects which can represent the information of an upper.
protocol UpperRepresentable {
    
    func getMid() -> Int
    func getName() -> String
    func getFace() -> URL
    func getBanner() -> URL?
    func getBannerNight() -> URL?
    func getSign() -> String?
    
}

extension BKAppEndpoint.BKUserSpaceResponse: UpperRepresentable {
    
    func getMid() -> Int {
        Int(card.mid)!
    }
    
    func getName() -> String {
        card.name
    }
    
    func getFace() -> URL {
        card.face
    }
    
    func getBanner() -> URL? {
        images.banner
    }
    
    func getBannerNight() -> URL? {
        images.bannerNight
    }
    
    func getSign() -> String? {
        card.sign
    }
}
