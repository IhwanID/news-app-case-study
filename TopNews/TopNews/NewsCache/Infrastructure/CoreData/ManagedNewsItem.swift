//
//  ManagedNewsItem.swift
//  TopNews
//
//  Created by Ihwan on 06/04/22.
//

import CoreData

@objc(ManagedNewsItem)
class ManagedNewsItem: NSManagedObject {
    @NSManaged var title: String
    @NSManaged var author: String?
    @NSManaged var source: String
    @NSManaged var newsDescription: String
    @NSManaged var content: String?
    @NSManaged var newsURL: URL
    @NSManaged var imageURL: URL?
    @NSManaged var publishedAt: Date
    @NSManaged var cache: ManagedCache
}

extension ManagedNewsItem {
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
