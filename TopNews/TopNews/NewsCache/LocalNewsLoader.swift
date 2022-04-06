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
    public typealias SaveResult = Result<Void, Error>
    
    public func save(_ items: [NewsItem], completion: @escaping (SaveResult) -> Void = { _ in }) {
        store.deleteCachedNews{ [weak self] deletionResult in
            guard let self = self else { return }
            
            switch deletionResult {
            case .success:
                self.cache(items, with: completion)
            case let .failure(error):
                completion(.failure(error))
            }
            
        }
    }
    
    private func cache(_ items: [NewsItem], with completion: @escaping (SaveResult) -> Void){
        self.store.insert(items.toLocal(), timestamp: self.currentDate()){ [weak self] insertionResult in
            guard self != nil else { return }
            completion(insertionResult)
        }
    }
}

extension LocalNewsLoader: NewsLoader {
    public typealias LoadResult = NewsLoader.Result
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self  else { return }
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(.some(cache)) where NewsCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                completion(.success(cache.news.toModels()))
            case .success:
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
            case let .success(.some(cache)) where !NewsCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                self.store.deleteCachedNews { _ in }
            case .success:
                break
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
