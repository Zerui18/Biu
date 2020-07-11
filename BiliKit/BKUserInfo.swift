//
//  BKUserInfo.swift
//  BiliKit
//
//  Created by Zerui Chen on 7/7/20.
//

import Foundation

public struct BKUserInfo {
    public let userId: Int
    public let accessToken: String
    
    init(from loginResponse: BKResponse<BKPassportEndpoint.LoginResponse>) {
        userId = loginResponse.data.userId
        accessToken = loginResponse.data.accessToken
    }
}
