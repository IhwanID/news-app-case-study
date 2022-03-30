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
