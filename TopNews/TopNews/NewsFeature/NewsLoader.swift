//
//  NewsLoader.swift
//  TopNews
//
//  Created by Ihwan on 06/03/22.
//

import Foundation

public enum LoadNewsResult {
    case success([NewsItem])
    case failure(Error)
}

public protocol NewsLoader {
    func load(completion: @escaping (LoadNewsResult) -> Void)
}
