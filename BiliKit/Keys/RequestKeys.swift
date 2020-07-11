//
//  RequestKeys.swift
//  Bili
//
//  Created by Zerui Chen on 4/7/20.
//

import Foundation

enum RequestMethod: String {
    case get, post
}

enum RequestHeader: String {
    case displayId = "Display-ID",
         buildVersionId = "Buvid",
         deviceId = "Device-ID",
         userAgent = "User-Agent",
         accept = "Accept",
         acceptLanguage = "Accept-Language",
         acceptEncoding = "Accept-Encoding"
}

enum RequestParam: String {
    case accessKey = "access_key",
         appKey = "appkey",
         actionKey = "actionkey",
         build = "build",
         buildVersionId = "buvid",
         channel = "channel",
         device = "device",
         source = "src",
         traceId = "trace_id",
         userId = "uid",
         verion = "version",
         mobileApp = "mobi_app",
         platform = "platform",
         timestamp = "ts",
         expire = "expire",
         mid = "mid",
         sign = "sign"
}
