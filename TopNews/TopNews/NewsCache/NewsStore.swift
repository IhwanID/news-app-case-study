//
//  NewsStore.swift
//  TopNews
//
//  Created by Ihwan on 29/03/22.
//

import Foundation

protocol NewsStore {
    typealias DeletionCompletion = (LocalNewsLoader.SaveResult) -> Void
    typealias InsertionCompletion = (LocalNewsLoader.SaveResult) -> Void
    
    func deleteCachedNews(completion: @escaping DeletionCompletion)
    func insert(_ items: [LocalNewsItem], timestamp: Date, completion: @escaping InsertionCompletion)
}

public struct LocalNewsItem: Equatable {
    public let title: String
    public let author: String?
    public let source: String
    public let description: String
    public let content: String?
    public let newsURL: URL
    public let imageURL: URL?
    public let publishedAt: Date
    
    public init(title: String, author: String?, source: String, description: String, content: String?, newsURL: URL, imageURL: URL?, publishedAt: Date) {
        self.title = title
        self.author = author
        self.source = source
        self.description = description
        self.content = content
        self.newsURL = newsURL
        self.imageURL = imageURL
        self.publishedAt = publishedAt
    }
}
