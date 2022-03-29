//
//  LocalNewsLoader.swift
//  TopNews
//
//  Created by Ihwan on 29/03/22.
//

import Foundation

class LocalNewsLoader {
    private let store: NewsStore
    private let currentDate: () -> Date
    
    init(store: NewsStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [NewsItem], completion: @escaping (Error?) -> Void = { _ in }) {
        store.deleteCachedNews{ [weak self] error in
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items, with: completion)
            }
        }
    }
    
    private func cache(_ items: [NewsItem], with completion: @escaping (Error?) -> Void){
        self.store.insert(items, timestamp: self.currentDate()){ [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

protocol NewsStore {
    
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedNews(completion: @escaping DeletionCompletion)
    func insert(_ items: [NewsItem], timestamp: Date, completion: @escaping InsertionCompletion)
}
