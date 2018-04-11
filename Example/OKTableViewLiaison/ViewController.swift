//
//  ViewController.swift
//  OKTableViewLiaison
//
//  Created by [01;31m[Kacct[m[K<blob>=dylanshine on 04/11/2018.
//  Copyright (c) 2018 [01;31m[Kacct[m[K<blob>=dylanshine. All rights reserved.
//

import UIKit
import OKTableViewLiaison

class ViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    private let liaison = OKTableViewLiaison()
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action: #selector(refreshSections), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        
        liaison.paginationDelegate = self
        liaison.liaise(tableView: tableView)
        
        let sections = Post.randomPosts()
            .map { return PostTableViewSection(post: $0, width: view.frame.width) }
        
        liaison.append(sections: sections)
    }
    
    @objc private func refreshSections() {
        let sections = Post.randomPosts()
            .map { return PostTableViewSection(post: $0, width: view.frame.width) }
        
        liaison.clearSections(replacedBy: sections, animated: false)
        refreshControl.endRefreshing()
    }
    
}

extension ViewController: OKTableViewLiaisonPaginationDelegate {
    
    func isPaginationEnabled() -> Bool {
        return liaison.sections.count < 9
    }
    
    func paginationStarted(indexPath: IndexPath) {
        
        liaison.scroll(to: indexPath)
        
        let sections: [OKAnyTableViewSection]
        
        if liaison.sections.count == 4 {
            sections = Post.paginatedPosts()
                .map { return PostTableViewSection(post: $0, width: view.frame.width) }
        } else {
            sections = Post.morePaginatedPosts()
                .map { return PostTableViewSection(post: $0, width: view.frame.width) }
        }
        
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2, execute: {
            self.liaison.append(sections: sections)
        })
    }
    
    func paginationEnded(indexPath: IndexPath) {
        
    }
}