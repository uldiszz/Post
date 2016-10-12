//
//  PostController.swift
//  Post
//
//  Created by Uldis Zingis on 11/10/16.
//  Copyright © 2016 Uldis Zingis. All rights reserved.
//

import Foundation

class PostController {
    
    static let baseURL = URL(string: "https://devmtn-post.firebaseio.com/posts/")
    static let endpoint = baseURL?.appendingPathExtension("json")
    
    weak var delegate: PostControllerDelegate?
    
    var posts: [Post]? {
        didSet {
            self.delegate?.postsWereUpdatedTo(posts: self.posts ?? [], on: self)
        }
    }
    
    init() {
        self.fetchPosts() { (posts) in
            self.posts = posts
        }
    }
    
    func fetchPosts(reset: Bool = true, completion: (([Post]) -> Void)?) {
        guard let url = PostController.endpoint else { return }
        
        let queryEndInterval = reset ? Date().timeIntervalSince1970 : self.posts?.last?.timestamp ?? Date().timeIntervalSince1970
        let urlParameters = [
            "orderBy": "\"timestamp\"",
            "endAt": "\(queryEndInterval)",
            "limitToLast": "16"]
        
        NetworkController.performRequest(for: url, httpMethod: .Get, urlParameters: urlParameters) { (data, error) in
            guard let data = data, let response = String(data: data, encoding: .utf8) else {
                NSLog("No data were returned.")
                return
            }
            
            guard let postDict = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: Any] else {
                NSLog("Could no serialize to json. \n Response: \(response)")
                return
            }
            
            var posts = postDict.flatMap { (post) -> Post? in
                let id = post.key as String
                let values = post.value as? [String: Any]
                return Post(json: values!, identifier: id)
            }
            
            posts = posts.sorted { $0.timestamp > $1.timestamp }
            
            if reset {
                self.posts = posts
            } else {
                self.posts?.append(contentsOf: posts)
            }

            DispatchQueue.main.async {
                completion?(posts)
            }
        }
    }
    
    func addPost(username: String, text: String) {
        let post = Post(username: username, text: text)
        
        guard let url = post.endpoint else { return }
        
        NetworkController.performRequest(for: url, httpMethod: .Put, body: post.jsonData) { (data, error) in
            guard let response = String(data: data!, encoding: .utf8) else { NSLog("No data were received."); return }
            if let error = error {
                NSLog("Error on post PUT: \(error.localizedDescription). \n Response: \(response)")
            } else {
                NSLog("Post PUT was successful. Response: \(response)")
            }
            self.fetchPosts(completion: nil)
        }
    }
}

protocol PostControllerDelegate: class {
    func postsWereUpdatedTo(posts: [Post], on postController: PostController)
}
