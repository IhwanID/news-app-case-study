//
//  NewsUIIntegrationTests+LoaderSpy.swift
//  TopNewsiOSTests
//
//  Created by Ihwan on 16/04/22.
//

import Foundation
import TopNewsiOS
import TopNews

extension NewsUIIntegrationTests {
    class LoaderSpy: NewsLoader, NewsImageDataLoader {
        
        
        private var newsRequest = [(NewsLoader.Result) -> Void]()
        
        var loadNewsCallCount: Int {
            return newsRequest.count
        }
        
        func load(completion: @escaping (NewsLoader.Result) -> Void) {
            newsRequest.append(completion)
        }
        
        func completeNewsLoading(with news: [NewsItem] = [],at index: Int = 0) {
            newsRequest[index](.success(news))
        }
        
        func completeNewsLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            newsRequest[index](.failure(error))
        }
        
        // MARK: - NewsImageDataLoader
        
        private struct TaskSpy: NewsImageDataLoaderTask {
            let cancelCallback: () -> Void
            func cancel() {
                cancelCallback()
            }
        }
        
        private var imageRequests = [(url: URL, completion: (NewsImageDataLoader.Result) -> Void)]()
        
        var loadedImageURLs: [URL] {
            return imageRequests.map { $0.url}
        }
        
        private(set) var cancelledImageURLs = [URL]()
        
        func loadImageData(from url: URL, completion: @escaping (NewsImageDataLoader.Result) -> Void) -> NewsImageDataLoaderTask {
            imageRequests.append((url, completion))
            
            return TaskSpy { [weak self] in
                self?.cancelledImageURLs.append(url)
            }
        }
        
        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequests[index].completion(.success(imageData))
        }
        
        func completeImageLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            imageRequests[index].completion(.failure(error))
        }
        
    }
}
