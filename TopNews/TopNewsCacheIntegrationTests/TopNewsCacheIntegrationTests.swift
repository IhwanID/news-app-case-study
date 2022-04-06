//
//  TopNewsCacheIntegrationTests.swift
//  TopNewsCacheIntegrationTests
//
//  Created by Ihwan on 06/04/22.
//

import XCTest
import TopNews

class TopNewsCacheIntegrationTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(news):
                XCTAssertEqual(news, [], "Expected empty news")
                
            case let .failure(error):
                XCTFail("Expected successful news result, got \(error) instead")
            }
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_deliversItemsSavedOnASeparateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let news = uniqueNews().models
        
        let saveExp = expectation(description: "Wait for save completion")
        sutToPerformSave.save(news) { saveError in
            XCTAssertNil(saveError, "Expected to save news successfully")
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
        
        let loadExp = expectation(description: "Wait for load completion")
        sutToPerformLoad.load { loadResult in
            switch loadResult {
            case let .success(newsResult):
                XCTAssertEqual(newsResult, news)
                
            case let .failure(error):
                XCTFail("Expected successful news result, got \(error) instead")
            }
            
            loadExp.fulfill()
        }
        wait(for: [loadExp], timeout: 1.0)
    }
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalNewsLoader {
        let storeBundle = Bundle(for: CoreDataNewsStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataNewsStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalNewsLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
