//
//  APIRequest.swift
//  Info-Med
//
//  Created by Gerardo Silva Razo on 05/05/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import Foundation

enum APIError : Error {
    case responseProblem
    case decodingProblem
    case encodingProblem
}

struct APIRequest {
    let resourceURL: URL
    
    // Create an instance of APIRequest with the endpoint of the server
    init(endpoint: String) {
        let resourceString = "https://info-med.herokuapp.com/api/\(endpoint)"
        guard let resourceURL = URL(string: resourceString) else { fatalError() }
        
        self.resourceURL = resourceURL
    }
    
    // HTTP Request to server with endpoint
    func faq(_ queryToSolve: Message, completion: @escaping(Result<Response, APIError>) -> Void) {
        print("Executing request")
        
        do {
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
