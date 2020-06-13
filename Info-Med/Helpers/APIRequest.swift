//
//  APIRequest.swift
//  Info-Med
//
//  Created by Gerardo Silva Razo A01136536 on 05/05/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import Foundation

// Enum to indicate the type of error from http request
enum APIError : Error {
    case responseProblem
    case decodingProblem
    case encodingProblem
}

// Struct that containts method to make HTTP requests to server
struct APIRequest {
    let resourceURL: URL
    
    // Initializer function that creates an instance of APIRequest with the endpoint of the server received
    init(endpoint: String) {
        let resourceString = "https://info-med.herokuapp.com/api/\(endpoint)"
        guard let resourceURL = URL(string: resourceString) else { fatalError() }
        
        self.resourceURL = resourceURL
    }
    
    // Function that makes HTTP request to server endpoint
    func response(_ queryToSolve: Query, completion: @escaping(Result<Response, APIError>) -> Void) {
        print("Executing request")
        
        do {
            // Configuration of the request
            var urlRequest = URLRequest(url: resourceURL)
            urlRequest.httpMethod = "POST"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONEncoder().encode(queryToSolve)
            
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let jsonData = data else {
                    completion(.failure(.responseProblem))
                    return
                }
                do {
                    // Decoding and returning JSON Response from server
                    let decoder = JSONDecoder()
                    let intentResponse = try decoder.decode(Response.self, from: jsonData)
                    completion(.success(intentResponse))
                } catch {
                    completion(.failure(.decodingProblem))
                }
            }
            dataTask.resume()
        } catch {
            completion(.failure(.encodingProblem))
        }
    }

}
