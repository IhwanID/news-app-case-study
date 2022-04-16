//
//  NewsImageDataLoader.swift
//  TopNewsiOS
//
//  Created by Ihwan on 16/04/22.
//

import Foundation

public protocol NewsImageDataLoaderTask {
    func cancel()
}

public protocol NewsImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> NewsImageDataLoaderTask
}
