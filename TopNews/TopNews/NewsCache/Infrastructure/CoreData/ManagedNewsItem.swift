//
//  ManagedNewsItem.swift
//  TopNews
//
//  Created by Ihwan on 06/04/22.
//

import CoreData

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
