//
//  CoreDataNewsStore.swift
//  TopNews
//
//  Created by Ihwan on 05/04/22.
//

import CoreData

public final class CoreDataNewsStore: NewsStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "NewsStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map {
                    return CachedNews(news: $0.localNews, timestamp: $0.timestamp)
                }})
        }
    }
    
    public func insert(_ news: [LocalNewsItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            completion(Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.news = ManagedNewsItem.item(from: news, in: context)
                
                try context.save()
            })
        }
    }
    
    public func deleteCachedNews(completion: @escaping DeletionCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
            })
        }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
    
}
