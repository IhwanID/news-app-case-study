//
//  NewsImagePresenter.swift
//  TopNewsiOS
//
//  Created by Ihwan on 17/04/22.
//

import Foundation
import TopNews

protocol NewsImageView {
    associatedtype Image
    
    func display(_ model: NewsImageViewModel<Image>)
}

final class NewsImagePresenter<View: NewsImageView, Image> where View.Image == Image {
    private let view: View
    private let imageTransformer: (Data) -> Image?
    
    internal init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImageData(for model: NewsItem) {
        view.display(NewsImageViewModel(
            author: model.author,
            title: model.title,
            image: nil,
            isLoading: true,
            shouldRetry: false))
    }
    
    private struct InvalidImageDataError: Error {}
    
    func didFinishLoadingImageData(with data: Data, for model: NewsItem) {
        guard let image = imageTransformer(data) else {
            return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }
        
        view.display(NewsImageViewModel(
            author: model.author,
            title: model.title,
            image: image,
            isLoading: false,
            shouldRetry: false))
    }
    
    func didFinishLoadingImageData(with error: Error, for model: NewsItem) {
        view.display(NewsImageViewModel(
            author: model.author,
            title: model.title,
            image: nil,
            isLoading: false,
            shouldRetry: true))
    }
}
