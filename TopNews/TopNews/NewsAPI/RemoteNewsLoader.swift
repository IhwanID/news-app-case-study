//
//  RemoteNewsLoader.swift
//  TopNews
//
//  Created by Ihwan on 06/03/22.
//

import Foundation

class RemoteNewsLoader {
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([NewsItem])
        case failure(Error)
    }
    
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(completion: @escaping (Result) -> Void) {
        client.get(from: url){ [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success(data, response):
               completion(NewsItemMapper.map(data, from: response))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    
}
