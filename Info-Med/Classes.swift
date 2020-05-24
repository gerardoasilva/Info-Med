//
//  Classes.swift
//  Info-Med
//
//  Created by user168593 on 4/21/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import UIKit

class Message: Codable {
    var text: String!
    var sender: String!
    
    init(text: String, sender: String){
        self.text = text
        self.sender = sender
    }
}

class Context: Codable {
    var name: String!
    var lifespanCount: Int!
    
    init(name: String, lifespanCount: Int) {
        self.name = name
        self.lifespanCount = lifespanCount
    }
}

class Query: Codable {
    
    var query: String!
    var contexts: [Context]?
    
    init(query: String!, contexts: [Context]?) {
        self.query = query
        self.contexts = contexts
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(query, forKey: .query)
        try container.encode(contexts, forKey: .contexts)
    }
}