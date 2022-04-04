//
//  CoreDataNewsStore.swift
//  TopNews
//
//  Created by Ihwan on 05/04/22.
//

import CoreData

public final class CoreDataNewsStore: NewsStore {
    private let container: NSPersistentContainer

    public init(bundle: Bundle = .main) throws {
            container = try NSPersistentContainer.load(modelName: "NewsStore", in: bundle)
        }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }

    public func insert(_ news: [LocalNewsItem], timestamp: Date, completion: @escaping InsertionCompletion) {

    }

    public func deleteCachedNews(completion: @escaping DeletionCompletion) {

    }

}

private extension NSPersistentContainer {
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStores(Swift.Error)
    }

    static func load(modelName name: String, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw LoadingError.modelNotFound
        }

        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        var loadError: Swift.Error?
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw LoadingError.failedToLoadPersistentStores($0) }

        return container
    }
}

private extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}

@objc(ManagedCache)
internal class ManagedCache: NSManagedObject {
    @NSManaged internal var timestamp: Date
    @NSManaged internal var news: NSOrderedSet
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
    
}
