//
//  ManagedCache.swift
//  TopNews
//
//  Created by Ihwan on 06/04/22.
//

import CoreData

@objc(ManagedCache)
class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var news: NSOrderedSet
}

extension ManagedCache {
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
