//
//  NewsCacheTestHelpers.swift
//  TopNewsTests
//
//  Created by Ihwan on 03/04/22.
//

import Foundation
@testable import TopNews

func uniqueItem() -> NewsItem {
    return NewsItem(title: "A title", author: "An Author", source: "A Source", description: "A Desc", content: "A content", newsURL: anyURL(), imageURL: anyURL(), publishedAt: Date())
}

func uniqueNews() -> (models: [NewsItem], local: [LocalNewsItem]) {
    let models = [uniqueItem(), uniqueItem()]
    let local = models.map { LocalNewsItem(title: $0.title, author: $0.author, source: $0.source, description: $0.description, content: $0.content, newsURL: $0.newsURL, imageURL: $0.imageURL, publishedAt: $0.publishedAt) }
    return (models, local)
}


extension Date {
    
    func minusNewsCacheMaxAge() -> Date {
        return adding(days: -7)
    }
    
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
