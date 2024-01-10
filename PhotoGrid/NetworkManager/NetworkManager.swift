//
//  NetworkManager.swift
//  PhotoGrid
//
//  Created by Saggy on 09/01/24.
//

import Foundation

enum NetworkError : Error {
    case jsonDecodingError(Error)
    case responseFetchError(Error)
    case invalidURL
    case invalidImageData
    case badServerResponse
}

protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

protocol NetworkFetchable {
    func makeHttpRequest<T: Decodable>(from endpointURL: String) async throws -> T
    func fetchData(from endpointURL: String) async throws -> Data
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
    
    func fetchData(from endpointURL: String) async throws -> Data {
        guard let url =  URL(string: endpointURL) else {
            throw NetworkError.invalidURL
        }
        
        do {
            let (responseData, _) = try await urlSession.data(from: url)
            return responseData
        } catch {
            throw NetworkError.responseFetchError(error)
        }
    }
}
