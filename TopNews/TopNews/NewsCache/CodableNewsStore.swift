//
//  CodableNewsStore.swift
//  TopNews
//
//  Created by Ihwan on 03/04/22.
//

import Foundation

class CodableNewsStore: NewsStore {
    
    private struct Cache: Codable {
        let news: [CodableNewsItem]
        let timestamp: Date
        
        var localNews: [LocalNewsItem] {
            return news.map { $0.local }
        }
    }
    
    private struct CodableNewsItem: Codable {
        public let title: String
        public let author: String?
        public let source: String
        public let description: String
        public let content: String?
        public let newsURL: URL
        public let imageURL: URL?
        public let publishedAt: Date
        
        public init(_ news: LocalNewsItem) {
            self.title = news.title
            self.author = news.author
            self.source = news.source
            self.description = news.description
            self.content = news.content
            self.newsURL = news.newsURL
            self.imageURL = news.imageURL
            self.publishedAt = news.publishedAt
        }
        
        var local: LocalNewsItem {
            return LocalNewsItem(title: title, author: author, source: source, description: description, content: content, newsURL: newsURL, imageURL: imageURL, publishedAt: publishedAt)
        }
    }
    
    private let queue = DispatchQueue(label: "\(CodableNewsStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        let storeURL = self.storeURL
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.empty)
            }
            
            do {
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.found(news: cache.localNews, timestamp: cache.timestamp))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func insert(_ news: [LocalNewsItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            do {
                let encoder = JSONEncoder()
                let cache = Cache(news: news.map(CodableNewsItem.init), timestamp: timestamp)
                let encoded = try encoder.encode(cache)
                try encoded.write(to: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    func deleteCachedNews(completion: @escaping DeletionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return completion(nil)
            }
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}
