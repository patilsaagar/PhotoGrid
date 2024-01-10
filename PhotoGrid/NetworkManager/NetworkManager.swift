//
//  NetworkManager.swift
//  PhotoGrid
//
//  Created by Saggy on 09/01/24.
//

import Foundation

enum NetworkError : Error {
    case jsonDecodingError(Error)
    case invalidURL
}

protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

protocol NetworkFetchable {
    func makeHttpRequest<T: Decodable>(from endpointURL: String) async throws -> T
}

class NetworkManager: NetworkFetchable {
    
    private var urlSession: URLSessionProtocol
    
    init(urlSession: URLSessionProtocol) {
        self.urlSession = urlSession
    }
    
    func makeHttpRequest<T: Decodable>(from endpointURL: String) async throws -> T {
        guard let url =  URL(string: endpointURL) else {
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, _) = try await urlSession.data(from: url)
                let response = try JSONDecoder().decode(T.self, from: data)
                return response
        } catch {
            throw NetworkError.jsonDecodingError(error)
        }
    }
}
