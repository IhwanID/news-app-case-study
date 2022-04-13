//
//  NewsViewController.swift
//  Prototype
//
//  Created by Ihwan on 13/04/22.
//

import UIKit

final class NewsViewController: UITableViewController {
    
    private var news = [NewsItemViewModel]()
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "NewsItemCell", for: indexPath) as! NewsItemCell
        let model = news[indexPath.row]
        cell.configure(with: model)
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refresh()
        tableView.setContentOffset(CGPoint(x: 0, y: -tableView.contentInset.top), animated: false)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    @IBAction func refresh() {
        refreshControl?.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if self.news.isEmpty {
                self.news = NewsItemViewModel.prototypeNews
                self.tableView.reloadData()
            }
            self.refreshControl?.endRefreshing()
        }
    }
    
}
