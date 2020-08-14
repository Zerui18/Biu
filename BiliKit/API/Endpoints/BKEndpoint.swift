//
//  BKEndpoint.swift
//  BiliKit
//
//  Created by Zerui Chen on 4/7/20.
//

import Foundation

/**
 Declares a set of related API endpoints which share the same url.
 */
public protocol BKEndpoint {
    
    var rawValue: String { get }
    
    /// The base url for the endpoint represented by the receiver.
    var baseURL: URL { get }
    
    var url: URL { get }
        
    /**
     Creates a BKRequest targeting endpoint represented by the receiver - using the specified method and optionally providing user-defined queries.
     
     The default implementation is provided by the protocol and should not be overriden.
     */
    func createRequest(using method: BKRequest.Method,
                                                 withQuery query: [String : String]?) -> BKRequest
}

// MARK: Default Impl
extension BKEndpoint {
    public var url: URL {
        baseURL.appendingPathComponent(rawValue)
    }
    
    public func createRequest(using method: BKRequest.Method,
                                                 withQuery query: [String : String]? = nil) -> BKRequest {
        BKRequest(method: method, endpoint: self, query: query ?? [:])
    }
}

// MARK: BKAnyEndpoint
public struct BKAnyEndpoint: BKEndpoint {
        
    public let rawValue: String = ""
    
    public let baseURL: URL = URL(fileURLWithPath: "/")
    
    public let url: URL
    
    public init(url: URL) {
        self.url = url
    }
    
}
