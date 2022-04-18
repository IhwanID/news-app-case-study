//
//  NewsImageDataLoaderPresentationAdapter.swift
//  TopNewsiOS
//
//  Created by Ihwan on 19/04/22.
//

import TopNews

final class NewsImageDataLoaderPresentationAdapter<View: NewsImageView, Image>: NewsImageCellControllerDelegate where View.Image == Image {
    private var task: NewsImageDataLoaderTask?
    private let model: NewsItem
    private let imageLoader: NewsImageDataLoader
    
    var presenter: NewsImagePresenter<View, Image>?
    
    init(model: NewsItem, imageLoader: NewsImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        
        let model = self.model
        if let url = model.imageURL {
            task = imageLoader.loadImageData(from: url) { [weak self] result in
                switch result {
                case let .success(data):
                    self?.presenter?.didFinishLoadingImageData(with: data, for: model)
                    
                case let .failure(error):
                    self?.presenter?.didFinishLoadingImageData(with: error, for: model)
                }
            }
        }
    }
    
    func didCancelImageRequest() {
        task?.cancel()
    }
    
}
