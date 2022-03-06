//
//  RemoteNewsLoader.swift
//  TopNews
//
//  Created by Ihwan on 06/03/22.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
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
    
    func load(completion: @escaping (Result) -> Void = {_ in }) {
        client.get(from: url){ result in
            switch result {
            case let .success(data, response):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                if let root = try? decoder.decode(Root.self, from: data) , response.statusCode == 200 {
                    completion(.success(root.news))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    
    private struct Root: Decodable {
        let articles: [Item]
        var news: [NewsItem] {
            articles.map { NewsItem(title: $0.title, author: $0.author, source: $0.source.name, description: $0.description, content: $0.content, newsURL: $0.url, imageURL: $0.urlToImage, publishedAt: $0.publishedAt) }
        }
    }
    
    private struct Item: Decodable {
        let title: String
        let author: String?
        let source: Source
        let description: String
        let content: String
        let url: URL
        let urlToImage: URL
        let publishedAt: Date
        
        var item: NewsItem {
            return NewsItem(title: title, author: author, source: source.name, description: description, content: content, newsURL: url, imageURL: urlToImage, publishedAt: publishedAt)
        }
    }
    
    private struct Source: Decodable {
        let name: String
    }
    
}
