//
//  NewsLoader.swift
//  TopNews
//
//  Created by Ihwan on 06/03/22.
//

import Foundation

enum LoadNewsResult {
    case success([NewsItem])
    case error(Error)
}

protocol NewsLoader {
    func load(completion: @escaping (LoadNewsResult) -> Void)
}
