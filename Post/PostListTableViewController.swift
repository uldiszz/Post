//
//  PostListTableViewController.swift
//  Post
//
//  Created by Uldis Zingis on 11/10/16.
//  Copyright © 2016 Uldis Zingis. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController, PostControllerDelegate {
    
    let postController = PostController()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableViewAutomaticDimension
        navigationController?.navigationBar.backgroundColor = UIColor.cyan
        postController.delegate = self
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postController.posts?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        guard let post = postController.posts?[indexPath.row] else { return UITableViewCell() }
        
        cell.textLabel?.text = post.text
        cell.detailTextLabel?.text = "Author: \(post.username) | Created at: \(TimeInterval.toReadableDateFormatString(timeInterval: post.timestamp))"
        return cell
    }
    
    func postsWereUpdatedTo(posts: [Post], on postController: PostController) {
        tableView.reloadData()
    }

    @IBAction func refrechTablePulled(_ sender: AnyObject) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        postController.fetchPosts { (posts) in
            self.tableView.reloadData()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    @IBAction func plusButtonTapped(_ sender: AnyObject) {
        self.presentNewPostAlert()
    }
    
    func presentNewPostAlert() {
        let alertController = UIAlertController(title: "Create new post", message: "", preferredStyle: .alert)
        
        var userNameTextField = UITextField()
        alertController.addTextField { (textField) in
            textField.placeholder = "Your message"
            userNameTextField = textField
        }
        var messageTextField = UITextField()
        alertController.addTextField { (textField) in
            textField.placeholder = "Name"
            messageTextField = textField
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let addAction = UIAlertAction(title: "Create", style: .default) { (_) in
            guard let username = userNameTextField.text, let text = messageTextField.text else {
                self.presentErrorAlert()
                return
            }
            
            if username != "" && text != "" {
                self.postController.addPost(username: username, text: text)
            } else {
                self.presentErrorAlert()
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        
        self.present(alertController, animated: true)
    }
    
    func presentErrorAlert() {
        let alertController = UIAlertController(title: "Invalid post!", message: "Username and/or message text field is/are empty!", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(ok)
        self.present(alertController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let posts = postController.posts else { return }
        if indexPath.row+1 >= posts.count {
            postController.fetchPosts(reset: false, completion: { (posts) in
                if !posts.isEmpty { tableView.reloadData() }
            })
        }
    }
}












