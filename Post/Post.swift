//
//  Post.swift
//  Post
//
//  Created by Uldis Zingis on 11/10/16.
//  Copyright © 2016 Uldis Zingis. All rights reserved.
//

import Foundation

struct Post {
    
    private let kText = "text"
    private let kTimestamp = "timestamp"
    private let kUsername = "username"
    private let kIdentifier = "identifier"
    
    let username: String
    let text: String
    let timestamp: TimeInterval
    let identifier: UUID
    
    var endpoint: URL? {
        return PostController.baseURL?.appendingPathComponent(self.identifier.uuidString).appendingPathExtension("json")
    }
    
    var jsonValue: [String: Any] {
        let postAsDict = [
            "\(self.identifier)": [kText: text, kTimestamp: timestamp, kUsername: username]
        ]
        
        return postAsDict
    }
    
    var jsonData: Data? {
        return try? JSONSerialization.data(withJSONObject: jsonValue, options: .prettyPrinted)
    }
    
    init(username: String, text: String, timestamp: TimeInterval = NSTimeIntervalSince1970, identifier: UUID = UUID()) {
        self.username = username
        self.text = text
        self.timestamp = timestamp
        self.identifier = identifier
    }
    
    init?(json: [String: Any], identifier: String) {
        guard let text = json[kText] as? String,
             let timestamp = json[kTimestamp] as? TimeInterval,
             let username = json[kUsername] as? String else { return nil }
        
        self.text = text
        self.timestamp = timestamp
        self.username = username
        if let id = json[kIdentifier] as? UUID {
            self.identifier = id
        } else {
            guard let id = UUID(uuidString: identifier) else { return nil }
            self.identifier = id
        }
    }
}

extension TimeInterval {
    static func toReadableDateFormatString(timeInterval: TimeInterval) -> String {
        let date = NSDate(timeIntervalSince1970: timeInterval)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date as Date)
    }
}
