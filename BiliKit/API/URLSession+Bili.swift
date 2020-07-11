//
//  URLRequest+Bili.swift
//  BiliKit
//
//  Created by Zerui Chen on 4/7/20.
//

import Foundation
import Combine

public extension URLSession {

    /// Fetch a URLRequest and decode the data to the desired type.
    func fetch<DataType: Codable>(_ request: URLRequest) -> AnyPublisher<DataType, BKError> {
        dataTaskPublisher(for: request)
            .map {
                $0.0
            }
            .tryMap { data in
                do {
                    return try JSONDecoder().decode(DataType.self, from: data)
                }
                catch let error as DecodingError {
                    let rawText = String(data: data, encoding: .utf8)!
                    throw BKError.decodingError(error: error, raw: rawText)
                }
            }
            .mapError { error -> BKError in
                if let error = error as? BKError {
                    return error
                }
                
                return BKError.networkError(reason: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
    
}
