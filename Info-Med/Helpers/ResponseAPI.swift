//
//  ResponseAPI.swift
//  Info-Med
//
//  Created by Gerardo Silva Razo on 05/05/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import Foundation

// Struct required to decode JSON Response from Dialogflow API
struct Response: Decodable {
    struct FulfillmentMessages: Decodable {
        struct Payload: Decodable {
            struct Fields: Decodable {
                struct Clinimetry: Decodable {
                    var numberValue: Int?
                }
                struct Suggestions: Decodable {
                    struct ListValue: Decodable {
                        struct Value: Decodable {
                            var stringValue: String
                        }
                        var values: [Value]
                    }
                    var listValue: ListValue
                }
                var clinimetry: Clinimetry?
                var suggestions: Suggestions?
            }
            var fields: Fields
        }
        var payload: Payload?
    }
    
    struct Context: Decodable {
        var name: String
        var lifespanCount: Int
    }
    
    struct Intent: Decodable {
        var displayName: String
        var isFallback: Bool
    }
    
    var fulfillmentMessages: [FulfillmentMessages]
    var outputContexts: [Context]
    var intent: Intent
    var fulfillmentText: String
}
