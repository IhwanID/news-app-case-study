//
//  NewsItemViewModel.swift
//  Prototype
//
//  Created by Ihwan on 13/04/22.
//

import Foundation

struct NewsItemViewModel {
    let author: String?
    let source: String
    let imageName: String
    let title: String
}

extension NewsItemViewModel {
    static var prototypeNews: [NewsItemViewModel] {
            return [
                NewsItemViewModel(author: "Budi", source: "CNN", imageName: "image-1", title: "Contoh Berita 1"),
                NewsItemViewModel(author: nil, source: "CNN", imageName: "image-1", title: "Contoh Berita 1"),
                NewsItemViewModel(author: "Budi", source: "CNN", imageName: "image-1", title: "Contoh Berita 1"),
                NewsItemViewModel(author: "Budi", source: "CNN", imageName: "image-1", title: "Contoh Berita 1"),
                NewsItemViewModel(author: "Budi", source: "CNN", imageName: "image-1", title: "Contoh Berita 1"),
                NewsItemViewModel(author: "Budi", source: "CNN", imageName: "image-1", title: "Contoh Berita 1")
            ]
    }
}
