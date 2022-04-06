//
//  NewsLoader.swift
//  TopNews
//
//  Created by Ihwan on 06/03/22.
//

import Foundation

public typealias LoadNewsResult = Result<[NewsItem], Error>

public protocol NewsLoader {
    func load(completion: @escaping (LoadNewsResult) -> Void)
}
