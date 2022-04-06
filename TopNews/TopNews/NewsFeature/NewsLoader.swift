//
//  NewsLoader.swift
//  TopNews
//
//  Created by Ihwan on 06/03/22.
//

import Foundation

public protocol NewsLoader {
    typealias Result = Swift.Result<[NewsItem], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
