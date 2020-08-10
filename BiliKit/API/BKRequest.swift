//
//  BKRequest.swift
//  BiliKit
//
//  Created by Zerui Chen on 5/7/20.
//

import Combine

// MARK: Constants
/// The api init time, to be used in certain requests.
fileprivate let initTime = Int(Date().timeIntervalSinceReferenceDate)

/// Dictionary of common headers.
fileprivate let commonHeaders = [
    RequestHeader.displayId.rawValue : "\(BKKeys.buildVersionId.rawValue)-\(initTime)",
    RequestHeader.buildVersionId.rawValue : BKKeys.buildVersionId.rawValue,
    RequestHeader.userAgent.rawValue : BKKeys.defaultUserAgent.rawValue,
    RequestHeader.deviceId.rawValue : BKKeys.hardwareId.rawValue,
//    "content-type" : "application/x-www-form-urlencoded; charset=utf-8",
//    "host" : "passport.bilibili.com"
]

//['user-agent', 'display-id', 'buvid', 'device-id', 'content-type', 'content-length', 'host']

/// Dictionary of common parameters.
fileprivate let commonParams = [
    RequestParam.appKey.rawValue : BKKeys.appKey.rawValue,
    RequestParam.build.rawValue : BKKeys.build.rawValue,
    RequestParam.channel.rawValue : BKKeys.channel.rawValue,
    RequestParam.mobileApp.rawValue : BKKeys.platform.rawValue,
    RequestParam.platform.rawValue : BKKeys.platform.rawValue,
]

// MARK: Percent Encoding
extension CharacterSet {
    /// https://stackoverflow.com/questions/41561853/couldnt-encode-plus-character-in-url-swift
    static let rfc3986Unreserved = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")
}

private func encode(_ string: String) -> String {
    return string.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!
}

// MARK: BKRequest
/// A request object encapsulating the endpoint and query to a bilibili api.
public struct BKRequest<ResponseData: Codable> {
    
    /// The request method.
    public enum Method: String {
        case get, post
    }
    
    /// The request method.
    public let method: Method
    
    /// The target endpoint.
    public let endpoint: BKEndpoint
    
    /// The dictionary of user-defined query parameters.
    public let query: [String:String]
    
    /// The dictionary of all query parameters (except sign).
    private var fullQuery: [String:String] {
        var fullQuery = query.merging(commonParams, uniquingKeysWith: { $1 })
        fullQuery[RequestParam.timestamp.rawValue] = String(Int(Date().timeIntervalSince1970))
        return fullQuery
    }
    
    /// Sorted and concatenated query string, excluding sign which will be calculated based on this.
    public var sortedQueryString: String {
        fullQuery.map {
            "\(encode($0.key))=\(encode($0.value))"
        }
        .sorted()
        .joined(separator: "&")
    }
    
    /// Creates a signed URLRequest.
    public func createURLRequest() -> URLRequest {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = commonHeaders
        // Get query and calc sign.
        let sortedQuery = sortedQueryString
        let sign = BKSec.calculateSign(from: sortedQuery)
        let signedQuery = "\(sortedQueryString)&sign=\(encode(sign))"
        // Fill body.
        switch method {
        case .get:
            request.url = URL(string: "\(request.url!.absoluteString)?\(signedQuery)")
        case .post:
            request.httpBody = signedQuery.data(using: .utf8)!
        }
        return request
    }
    
    /// Returns a Publisher that fetches this request without authentication.
    public func fetch() -> AnyPublisher<BKResponse<ResponseData>, BKError> {
        return URLSession.shared.fetch(createURLRequest())
    }
    
    /// Returns a Publisher that fetches this request with authentication.
    public func fetchAuthenticated() -> AnyPublisher<BKResponse<ResponseData>, BKError> {
        let request = createURLRequest()
        // Try requesting a authenticated request.
        if let authenticatedRequest = BKClient.shared.authenticateRequest(request) {
            return URLSession.shared.fetch(authenticatedRequest)
        }
        // Return a BKError indicating no auth.
        return Fail(error: BKError.authenticationNeeded)
            .eraseToAnyPublisher()
    }
    
}
