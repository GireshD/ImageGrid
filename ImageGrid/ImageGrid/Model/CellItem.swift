//
//  CellItem.swift
//  ImageGrid
//
//  Created by Giresh Dora on 17/04/24.
//

import UIKit

enum Section{
    case main
}

class CellItem: Hashable {
    
    var image: UIImage!
    let imageModel: Image!
    let identifier = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: CellItem, rhs: CellItem) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    init(image: UIImage, imageModel: Image) {
        self.image = image
        self.imageModel = imageModel
    }
}
