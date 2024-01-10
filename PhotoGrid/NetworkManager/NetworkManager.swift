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
    func fetchData<T: Decodable>(from url: String) async throws -> T
}

class NetworkManager: NetworkFetchable {
    
    private var urlSession: URLSessionProtocol
    
    init(urlSession: URLSessionProtocol) {
        self.urlSession = urlSession
    }
    
    func fetchData<T: Decodable>(from url: String) async throws -> T {
        guard let url =  URL(string: url) else {
            throw NetworkError.invalidURL
        }
        
        do {
            let (responseData, _) = try await urlSession.data(from: url)
                let response = try JSONDecoder().decode(T.self, from: responseData)
                return response
        } catch {
            throw NetworkError.jsonDecodingError(error)
        }
    }
}
