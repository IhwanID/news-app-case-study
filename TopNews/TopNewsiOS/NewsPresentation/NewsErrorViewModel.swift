//
//  NewsErrorViewModel.swift
//  TopNewsiOS
//
//  Created by Ihwan on 19/04/22.
//

import Foundation

struct NewsErrorViewModel {
    let message: String?
    
    static var noError: NewsErrorViewModel {
        return NewsErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> NewsErrorViewModel {
        return NewsErrorViewModel(message: message)
    }
}
