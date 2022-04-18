//
//  NewsViewControllerTests+Localization.swift
//  TopNewsiOSTests
//
//  Created by Ihwan on 18/04/22.
//

import XCTest
import TopNewsiOS

extension NewsViewControllerTests {
    func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "News"
        let bundle = Bundle(for: NewsViewController.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}
