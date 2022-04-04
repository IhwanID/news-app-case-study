//
//  CoreDataNewsStore.swift
//  TopNews
//
//  Created by Ihwan on 05/04/22.
//

import Foundation

public final class CoreDataNewsStore: NewsStore {
    public init() {}

    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }

    public func insert(_ feed: [LocalNewsItem], timestamp: Date, completion: @escaping InsertionCompletion) {

    }

    public func deleteCachedNews(completion: @escaping DeletionCompletion) {

    }

}
