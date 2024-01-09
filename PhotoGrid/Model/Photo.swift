//
//  Photo.swift
//  PhotoGrid
//
//  Created by Saggy on 09/01/24.
//

import Foundation

struct Photo: Codable {
    let id, author: String
    let width, height: Int
    let downloadURL: String

    enum CodingKeys: String, CodingKey {
        case id, author, width, height
        case downloadURL = "download_url"
    }
}
