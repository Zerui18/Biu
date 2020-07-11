//
//  BKResponse.swift
//  BiliKit
//
//  Created by Zerui Chen on 4/7/20.
//

import Foundation

public struct BKResponse <Data: Codable>: Codable {
    
    public let code: Int
    public var message: String?
    
    public let data: Data
    
}
