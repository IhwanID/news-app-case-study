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
        
        expect(sut, toLoad: [])
    }
    
    func test_load_deliversItemsSavedOnASeparateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let news = uniqueNews().models
        
        save(news, with: sutToPerformSave)
        
        expect(sutToPerformLoad, toLoad: news)
    }
    
    func test_save_overridesItemsSavedOnASeparateInstance() {
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformLastSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let firstNews = uniqueNews().models
        let latestNews = uniqueNews().models
        
        save(firstNews, with: sutToPerformFirstSave)
        save(latestNews, with: sutToPerformLastSave)
        expect(sutToPerformLoad, toLoad: latestNews)
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
    
    private func expect(_ sut: LocalNewsLoader, toLoad expectedNews: [NewsItem], file: StaticString = #file, line: UInt = #line){
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(loadedNews):
                XCTAssertEqual(loadedNews, expectedNews, file: file, line: line)
                
            case let .failure(error):
                XCTFail("Expected successful news result, got \(error) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func save(_ news: [NewsItem], with loader: LocalNewsLoader, file: StaticString = #file, line: UInt = #line) {
        let saveExp = expectation(description: "Wait for save completion")
        loader.save(news) { result in
            if case let Result.failure(error) = result {
                XCTAssertNil(error, "Expected to save feed successfully", file: file, line: line)
            }
            
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
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
