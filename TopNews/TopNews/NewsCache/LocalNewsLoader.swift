//
//  LocalNewsLoader.swift
//  TopNews
//
//  Created by Ihwan on 29/03/22.
//

import Foundation

public class LocalNewsLoader {
    
    private let store: NewsStore
    private let currentDate: () -> Date
    
    public init(store: NewsStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
}

extension LocalNewsLoader {
    public typealias SaveResult = Error?
    
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
    
    private func cache(_ items: [NewsItem], with completion: @escaping (SaveResult) -> Void){
        self.store.insert(items.toLocal(), timestamp: self.currentDate()){ [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

extension LocalNewsLoader: NewsLoader {
    public typealias LoadResult = LoadNewsResult
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self  else { return }
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .found(news, timestamp) where NewsCachePolicy.validate(timestamp, against: self.currentDate()):
                completion(.success(news.toModels()))
            case .found, .empty:
                completion(.success([]))
            }
        }
    }
}

extension LocalNewsLoader {
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure:
                self.store.deleteCachedNews { _ in }
            case let .found(_, timestamp) where !NewsCachePolicy.validate(timestamp, against: self.currentDate()):
                self.store.deleteCachedNews { _ in }
            case .empty, .found: break
            }
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
