//
//  SharedTestHelper.swift
//  TopNewsTests
//
//  Created by Ihwan on 03/04/22.
//

import Foundation

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}
