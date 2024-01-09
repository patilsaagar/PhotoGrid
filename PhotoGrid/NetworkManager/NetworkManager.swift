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

protocol NetworkFetchable {
    func fetchData() async throws -> [Photo]
}

class NetworkManager: NetworkFetchable {
    
    func fetchData() async throws -> [Photo] {
        guard let url =  URL(string: APIConstants.endpoint) else {
            throw NetworkError.invalidURL
        }
        
        let (responseData, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode([Photo].self, from: responseData)
            return response
    }
}
