//
//  Coverage.swift
//  ImageGrid
//
//  Created by Giresh Dora on 17/04/24.
//

import Foundation


struct Coverage: Codable{
    let id: String
    let title: String
    let image: Image
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case image = "thumbnail"
    }
}

struct Image: Codable {
    let id: String
    let domain: String
    let basePath: String
    let key: String
}
