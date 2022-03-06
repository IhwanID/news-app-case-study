//
//  RemoteNewsLoaderTests.swift
//  RemoteNewsLoaderTests
//
//  Created by Ihwan on 06/03/22.
//

import XCTest
@testable import TopNews

class RemoteNewsLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(.invalidData), when: {
                let json = ["items": []]
                let data =  try! JSONSerialization.data(withJSONObject: json)
                
                client.complete(withStatusCode: code, data: data, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.invalidData), when: {
            let invalidJSON = Data( "invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        let item1 = makeItem(title: "News 1", author: nil, source: "A Source", description: "A Desc", content: "A Content", newsURL: URL(string: "http://another-url.com")!, imageURL: URL(string: "http://another-url.com")!, publishedAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"))
        
        let item2 = makeItem(title: "News 2", author: "A Person", source: "Source", description: "Desc", content: "Content", newsURL: URL(string: "http://another-url.com")!, imageURL: URL(string: "http://another-url.com")!, publishedAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"))
        
        let items = [item1.model, item2.model]
        
        expect(sut, toCompleteWith: .success(items), when: {
            let json = makeItemsJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        })
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "http://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteNewsLoader? = RemoteNewsLoader(url: url, client: client)
        
        var capturedResults = [RemoteNewsLoader.Result]()
        sut?.load { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteNewsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteNewsLoader(url: url, client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
    
    private func expect(_ sut: RemoteNewsLoader, toCompleteWith result: RemoteNewsLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        var capturedResults = [RemoteNewsLoader.Result]()
        sut.load { capturedResults.append($0) }
        
        action()
        
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }
    
    private func makeItem(title: String, author: String? = nil, source: String, description: String,  content: String, newsURL: URL, imageURL: URL, publishedAt: (date: Date, iso8601String: String)) -> (model: NewsItem, json: [String: Any]) {
        let item = NewsItem(title: title, author: author, source: source, description: description, content: content, newsURL: newsURL, imageURL: imageURL, publishedAt: publishedAt.date)
        
        let json: [String: Any] = [
            "title": title,
            "author": author,
            "description": description,
            "content": content,
            "url": newsURL.absoluteString,
            "urlToImage": imageURL.absoluteString,
            "publishedAt": publishedAt.iso8601String,
            "source": [
                "name": source
            ]
        ].compactMapValues { $0 }
        
        return (item, json)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["articles": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs : [URL] {
            return messages.map { $0.url }
        }
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success(data, response))
        }
        
    }
    
}
