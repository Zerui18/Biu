//
//  BKSec.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 4/14/19.
//  Copyright (c) 2017-2020 ApolloZhu. MIT License.
//

/// Security related algorithms.
public enum BKSec {
    
    /// Calculate the param sign, for the given string of sorted queries.
    static func calculateSign(from query: String) -> String {
        let data = (query + BKKeys.appSecret.rawValue).data(using: .utf8)!
        return md5Hex_CK(data)
    }
    
}
