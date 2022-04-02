//
//  LocalNewsLoader.swift
//  TopNews
//
//  Created by Ihwan on 29/03/22.
//

import Foundation

class LocalNewsLoader {
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadNewsResult
    
    private let store: NewsStore
    private let currentDate: () -> Date
    
    init(store: NewsStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [NewsItem], completion: @escaping (SaveResult) -> Void = { _ in }) {
        store.deleteCachedNews{ [weak self] error in
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items, with: completion)
            }
        }
    }
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .found(news, _):
                completion(.success(news.toModels()))
                
            case .empty:
                completion(.success([]))
            }
        }
    }
    
    private func cache(_ items: [NewsItem], with completion: @escaping (SaveResult) -> Void){
        self.store.insert(items.toLocal(), timestamp: self.currentDate()){ [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

private extension Array where Element == NewsItem {
    func toLocal() -> [LocalNewsItem] {
        return map { LocalNewsItem(title: $0.title, author: $0.author, source: $0.source, description: $0.description, content: $0.content, newsURL: $0.newsURL, imageURL: $0.imageURL, publishedAt: $0.publishedAt) }
    }
}

private extension Array where Element == LocalNewsItem {
    func toModels() -> [NewsItem] {
        return map { NewsItem(title: $0.title, author: $0.author, source: $0.source, description: $0.description, content: $0.content, newsURL: $0.newsURL, imageURL: $0.imageURL, publishedAt: $0.publishedAt) }
    }
}
