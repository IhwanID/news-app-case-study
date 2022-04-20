//
//  NewsImagePresenter.swift
//  TopNews
//
//  Created by Ihwan on 20/04/22.
//

import Foundation

public protocol NewsImageView {
    associatedtype Image
    
    func display(_ model: NewsImageViewModel<Image>)
}

public final class NewsImagePresenter<View: NewsImageView, Image> where View.Image == Image {
    private let view: View
    private let imageTransformer: (Data) -> Image?
    
    public init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    public func didStartLoadingImageData(for model: NewsItem) {
        view.display(NewsImageViewModel(author: model.author, title: model.title, image: nil, isLoading: true, shouldRetry: false))
    }
    
    public func didFinishLoadingImageData(with data: Data, for model: NewsItem) {
        let image = imageTransformer(data)
        view.display(NewsImageViewModel(author: model.author, title: model.title, image: image, isLoading: false, shouldRetry: image == nil))
    }
    
    public func didFinishLoadingImageData(with error: Error, for model: NewsItem) {
        view.display(NewsImageViewModel(
            author: model.author,
            title: model.title,
            image: nil,
            isLoading: false,
            shouldRetry: true))
    }
}
