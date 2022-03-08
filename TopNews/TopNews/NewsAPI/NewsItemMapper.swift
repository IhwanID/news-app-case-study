//
//  NewsItemMapper.swift
//  TopNews
//
//  Created by Ihwan on 06/03/22.
//

import Foundation

final class NewsItemMapper {
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
        let content: String?
        let url: URL
        let urlToImage: URL?
        let publishedAt: Date
    }
    
    private struct Source: Decodable {
        let name: String
    }
    
    private static var OK_200: Int { return 200 }
    
    static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteNewsLoader.Result {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard response.statusCode == OK_200,
              let root = try? decoder.decode(Root.self, from: data)
        else {
            return .failure(RemoteNewsLoader.Error.invalidData)
        }
        
        return .success(root.news)
    }
}
