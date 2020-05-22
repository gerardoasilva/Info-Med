//
//  ResponseFAQ.swift
//  Info-Med
//
//  Created by Gerardo Silva Razo on 05/05/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import Foundation
import SwiftyJSON

// Structure of the required to decode attributes from Dialogflow-Server response
//struct Response: Decodable {
//    var fulfillmentText: String
//}

/* This WORKS to decode Custom Payload from agent 2
 
struct Response: Decodable {
    struct Fulfillment: Decodable {
        struct Payload: Decodable {
            struct Fields: Decodable {
                struct Message: Decodable {
                    var text: String
                    private enum CodingKeys: String, CodingKey {
                       case text = "stringValue"
                    }
                }
                struct Suggestions: Decodable {
                    struct ListValue: Decodable {
                        struct Value: Decodable {
                            var suggestion: String
                            private enum CodingKeys: String, CodingKey {
                                case suggestion = "stringValue"
                            }
                        }
                        var values: [Value]?
                    }
                    var listValue: ListValue
                }
                var responseText: Message
                var suggestions: Suggestions
            }
            var fields: Fields
        }
        var payload: Payload
    }
    var fulfillmentMessages: [Fulfillment]
}
*/






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
    var fulfillmentMessages: [FulfillmentMessages]
    var outputContexts: [Context]
    var fulfillmentText: String
}
