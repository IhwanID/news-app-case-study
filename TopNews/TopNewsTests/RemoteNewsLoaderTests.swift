//
//  RemoteNewsLoaderTests.swift
//  RemoteNewsLoaderTests
//
//  Created by Ihwan on 06/03/22.
//

import XCTest
@testable import TopNews

class RemoteNewsLoader {
    let client: HTTPClient
    let url: URL
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class RemoteNewsLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertNil(client.requestedURL)
    }
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteNewsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteNewsLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        
        func get(from url: URL) {
            requestedURL = url
        }
    }
    
}
