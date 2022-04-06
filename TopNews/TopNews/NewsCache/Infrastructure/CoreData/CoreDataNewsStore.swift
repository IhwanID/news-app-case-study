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
            do {
                
                if let cache = try ManagedCache.find(in: context)  {
                    completion(.found(
                        news: cache.localNews,
                        timestamp: cache.timestamp))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ news: [LocalNewsItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.news = ManagedNewsItem.item(from: news, in: context)
                
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func deleteCachedNews(completion: @escaping DeletionCompletion) {
        perform { context in
            do {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
    
}

@objc(ManagedCache)
internal class ManagedCache: NSManagedObject {
    @NSManaged internal var timestamp: Date
    @NSManaged internal var news: NSOrderedSet
    
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try find(in: context).map(context.delete)
        return ManagedCache(context: context)
    }
    
    var localNews: [LocalNewsItem] {
        return news.compactMap { ($0 as? ManagedNewsItem)?.local }
    }
    
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
}

@objc(ManagedNewsItem)
internal class ManagedNewsItem: NSManagedObject {
    @NSManaged internal var title: String
    @NSManaged internal var author: String?
    @NSManaged internal var source: String
    @NSManaged internal var newsDescription: String
    @NSManaged internal var content: String?
    @NSManaged internal var newsURL: URL
    @NSManaged internal var imageURL: URL?
    @NSManaged internal var publishedAt: Date
    @NSManaged internal var cache: ManagedCache
    
    static func item(from localNews: [LocalNewsItem], in context: NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(array: localNews.map { local in
            let managed = ManagedNewsItem(context: context)
            managed.title = local.title
            managed.author = local.author
            managed.source = local.source
            managed.newsDescription = local.description
            managed.content = local.content
            managed.newsURL = local.newsURL
            managed.imageURL = local.imageURL
            managed.publishedAt = local.publishedAt
            return managed
        })
    }
    
    var local: LocalNewsItem {
        return LocalNewsItem(title: title, author: author, source: source, description: newsDescription, content: content, newsURL: newsURL, imageURL: imageURL, publishedAt: publishedAt)
    }
}
