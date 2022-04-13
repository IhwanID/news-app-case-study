//
//  NewsViewController.swift
//  Prototype
//
//  Created by Ihwan on 13/04/22.
//

import UIKit

final class NewsViewController: UITableViewController {
    
    private let news = NewsItemViewModel.prototypeNews
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "NewsItemCell", for: indexPath) as! NewsItemCell
        let model = news[indexPath.row]
        cell.configure(with: model)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
}
