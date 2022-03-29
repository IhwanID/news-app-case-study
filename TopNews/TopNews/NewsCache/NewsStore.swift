//
//  NewsStore.swift
//  TopNews
//
//  Created by Ihwan on 29/03/22.
//

import Foundation

protocol NewsStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedNews(completion: @escaping DeletionCompletion)
    func insert(_ items: [NewsItem], timestamp: Date, completion: @escaping InsertionCompletion)
}
