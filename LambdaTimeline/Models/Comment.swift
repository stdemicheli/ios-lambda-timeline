//
//  Comment.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import FirebaseAuth

struct Comment: FirebaseConvertible, Equatable {
    
    static private let textKey = "text"
    static private let author = "author"
    static private let timestampKey = "timestamp"
    static private let audioURL = "audioURL"
    
    let text: String?
    let audioURL: URL?
    let author: Author
    let timestamp: Date
    
    init(text: String? = nil, author: Author, timestamp: Date = Date(), audioURL: URL? = nil) {
        self.text = text
        self.audioURL = audioURL
        self.author = author
        self.timestamp = timestamp
    }
    
    init?(dictionary: [String : Any]) {
        guard let text = dictionary[Comment.textKey] as? String,
            let authorDictionary = dictionary[Comment.author] as? [String: Any],
            let author = Author(dictionary: authorDictionary),
            let timestampTimeInterval = dictionary[Comment.timestampKey] as? TimeInterval,
            let audioURL = dictionary[Comment.audioURL] as? URL else { return nil }
        
        self.text = text
        self.audioURL = audioURL
        self.author = author
        self.timestamp = Date(timeIntervalSince1970: timestampTimeInterval)
    }
    
    var dictionaryRepresentation: [String: Any] {
        return [Comment.textKey: text,
                Comment.author: author.dictionaryRepresentation,
                Comment.timestampKey: timestamp.timeIntervalSince1970,
                Comment.audioURL: audioURL]
    }
}
