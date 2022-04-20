//
//  NewsErrorViewModel.swift
//  TopNews
//
//  Created by Ihwan on 20/04/22.
//

import Foundation

public struct NewsErrorViewModel {
    public let message: String?
    
    static var noError: NewsErrorViewModel {
        return NewsErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> NewsErrorViewModel {
        return NewsErrorViewModel(message: message)
    }
}
