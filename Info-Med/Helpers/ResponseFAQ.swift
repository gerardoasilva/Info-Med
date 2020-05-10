//
//  ResponseFAQ.swift
//  Info-Med
//
//  Created by Gerardo Silva Razo on 05/05/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import Foundation

// Structure of the required to decode attributes from Dialogflow-Server response
struct Response: Decodable {
    var fulfillmentText: String
}
