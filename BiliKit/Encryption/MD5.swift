//
//  MD5.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 12/19/19.
//  Copyright (c) 2017-2020 ApolloZhu. MIT License.
//

import Foundation
import CryptoKit

extension Sequence where Element == UInt8 {
    /// Converts bytes to hex representation.
    var hexString: String {
        return reduce(into: "") { $0 += String(format: "%02hhx", $1) }
    }
}

extension BKSec {
    /// Calculate MD5 using CryptoKit.
    /// - Parameter data: the data to run through md5.
    static func md5Hex_CK(_ data: Data) -> String {
        return Insecure.MD5.hash(data: data).hexString
    }
}

