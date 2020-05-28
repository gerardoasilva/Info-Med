//
//  Classes.swift
//  Info-Med
//
//  Created by user168593 on 4/21/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import UIKit

// Enum that has the type of agents available in dialogflow
enum Agent: String {
    case faq = "faq"
    case questionnaire = "questionnaire"
}

// Enum to know what option from the side menu is pressed
enum MenuOption {
    case info
    case faq
    case questionnaire
    case history
    case signOut
}

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

// Class query that is encoded to send as json to make a request to the API
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
/*
class User: Codable {
    var firstName: String!
    var lastName: String!
    var phoneNumber: String!
    var email: String!

    init(firstName: String, lastName: String, phoneNumber: String, email: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.email = email
    }
}

struct currentUser  {
    var uid: String
    var firstName: String
    var lastName: String
    var phoneNumber: String

    init(uid: String, dictionary: [String: Any]) {
    self.uid = uid
    self.firstName = dictionary["firstName"] as? String ?? "-"
    self.lastName = dictionary["lastName"] as? String ?? "-"
    self.phoneNumber = dictionary["phoneNumber"] as? String ?? "-"
    }
    
}
 */
