//
//  NewsStore.swift
//  TopNews
//
//  Created by Ihwan on 29/03/22.
//

import Foundation

public enum RetrieveCachedNewsResult {
    case empty
    case found(news: [LocalNewsItem], timestamp: Date)
    case failure(Error)
}

protocol NewsStore {
    typealias DeletionCompletion = (LocalNewsLoader.SaveResult) -> Void
    typealias InsertionCompletion = (LocalNewsLoader.SaveResult) -> Void
    typealias RetrievalCompletion = (RetrieveCachedNewsResult) -> Void
    
    func deleteCachedNews(completion: @escaping DeletionCompletion)
    func insert(_ items: [LocalNewsItem], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
