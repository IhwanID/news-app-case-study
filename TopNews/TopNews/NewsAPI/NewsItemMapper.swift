//
//  NewsItemMapper.swift
//  TopNews
//
//  Created by Ihwan on 06/03/22.
//

import Foundation

internal struct RemoteNewsItem: Decodable {
    internal let title: String
    internal let author: String?
    internal let source: Source
    internal let description: String
    internal let content: String?
    internal let url: URL
    internal let urlToImage: URL?
    internal let publishedAt: Date
}

internal struct Source: Decodable {
    internal let name: String
}

final class NewsItemMapper {
    private struct Root: Decodable {
        let articles: [RemoteNewsItem]
    }
    
    private static var OK_200: Int { return 200 }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteNewsItem]{
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard response.statusCode == OK_200,
              let root = try? decoder.decode(Root.self, from: data) else {
                  throw RemoteNewsLoader.Error.invalidData
              }
        
        return root.articles
    }
}
