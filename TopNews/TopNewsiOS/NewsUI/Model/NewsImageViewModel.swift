//
//  NewsImageViewModel.swift
//  TopNewsiOS
//
//  Created by Ihwan on 16/04/22.
//

import Foundation
import TopNews

final class NewsImageViewModel<Image> {
    typealias Observer<T> = (T) -> Void

    private var task: NewsImageDataLoaderTask?
    private let model: NewsItem
    private let imageLoader: NewsImageDataLoader
    private let imageTransformer: (Data) -> Image?

    init(model: NewsItem, imageLoader: NewsImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }

    var author: String? {
        return model.author
    }

    var title: String?  {
        return model.title
    }

    var hasAuthor: Bool {
        return author != nil
    }

    var onImageLoad: Observer<Image>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?

    func loadImageData() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        if let url = model.imageURL {
            task = imageLoader.loadImageData(from: url) { [weak self] result in
                self?.handle(result)
            }
        }
    }

    private func handle(_ result: NewsImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(imageTransformer) {
            onImageLoad?(image)
        } else {
            onShouldRetryImageLoadStateChange?(true)
        }
        onImageLoadingStateChange?(false)
    }

    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
}
