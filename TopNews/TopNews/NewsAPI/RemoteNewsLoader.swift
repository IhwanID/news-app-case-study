//
//  RemoteNewsLoader.swift
//  TopNews
//
//  Created by Ihwan on 06/03/22.
//

import Foundation

public enum HTTPClientResult {
    case success(HTTPURLResponse)
    case failure(Error)
}

protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

class RemoteNewsLoader {
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
    }
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(completion: @escaping (Error) -> Void = {_ in }) {
        client.get(from: url){ _ in
            completion(.connectivity)
        }
    }
}
