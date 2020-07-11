//
//  RSA.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 3/23/20.
//  Copyright (c) 2017-2020 ApolloZhu. MIT License.
//

import Foundation
#if canImport(BKFoundation)
import BKFoundation
#endif

#if canImport(Security)
import Security
#else
#error("RSA: NO ENCRYPTION BACKEND")
#endif

public extension BKSec {
    /// Compute the digest using RSA PKCS1.
    ///
    /// - Copyright: Copyright (c) 2015 Scoop Technologies, Inc.
    /// [MIT License](https://github.com/TakeScoop/SwiftyRSA/blob/master/LICENSE).
    ///
    /// - Parameters:
    ///   - string: the data to be encrypted.
    ///   - publicKey: contents of a `.pem` file.
    static func rsaEncrypt(_ string: String, with publicKey: String) -> String? {
        let stringData = string.data(using: .utf8)!

        let publicKey = publicKey
            .replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "\n", with: "")
        
        let keyData = Data(base64Encoded: publicKey)!

        return encrypt_Sec(stringData, keyData: keyData)
    }

    /// Calculates digest using RSA PCKS1.
    /// - Parameters:
    ///   - stringData: string to find digest for.
    ///   - keyData: public key data.
    private static func encrypt_Sec(_ stringData: Data, keyData: Data) -> String? {
        var error: Unmanaged<CFError>? = nil
        var errorDescription: String {
            return (error!.takeRetainedValue() as Error).localizedDescription
        }
        guard let key = SecKeyCreateWithData(keyData as CFData, [
            kSecAttrType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits: (keyData.count * 8) as NSNumber,
            ] as CFDictionary, &error) else {
                return nil
        }
        guard SecKeyIsAlgorithmSupported(key, .encrypt, .rsaEncryptionPKCS1) else {
            return nil
        }
        guard let data = SecKeyCreateEncryptedData(
            key, .rsaEncryptionPKCS1, stringData as CFData, &error) else {
                return nil
        }
        return (data as Data).base64EncodedString()
    }
}
