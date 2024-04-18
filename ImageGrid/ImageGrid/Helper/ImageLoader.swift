//
//  ImageLoader.swift
//  ImageGrid
//
//  Created by Giresh Dora on 17/04/24.
//

import Foundation
import UIKit

class ImageLoader {
    static let shared = ImageLoader()
    private let cachedImages = NSCache<NSString,UIImage>()
    private var loadingResponses = [NSURL: [(CellItem, UIImage?) -> Void]]()
    var placeHolderImage = UIImage(systemName: "rectangle")!
    private var errorImg = UIImage(named: "errorImg")!
    private let fileManager = LocalFileManager.shared
    
    
    private init() {}
    
    final func image(id: NSString) -> UIImage? {
        return cachedImages.object(forKey: id)
    }
    
    final func load(cellItem: CellItem, completion: @escaping (CellItem, UIImage?) -> Void){
        
        //Check for a cached image
        if let cachedImage = image(id: cellItem.imageModel.id as NSString){
            completion(cellItem, cachedImage)
            return
        }
        
        //Check for Disk
        if let diskSaveItem = fileManager.getImage(imageName: cellItem.imageModel.id, key: cellItem.imageModel.key),
           let image = diskSaveItem.0,
           let imageData = diskSaveItem.1
        {
            //Save to cache
            self.cachedImages.setObject(image, forKey: cellItem.imageModel.id as NSString, cost: imageData.count)
            completion(cellItem, image)
            return
        }
        
        //Create image url with the formate imageURL = domain + "/" + basePath + "/0/" + key
        let urlString = String("\(cellItem.imageModel.domain)/\(cellItem.imageModel.basePath)/0/\(cellItem.imageModel.key)")
        guard let url = NSURL(string: urlString) else {
            completion(cellItem,errorImg)
            return
        }
        
        //In case there are more than one requestor for the image, we append their completion block
        if loadingResponses[url] != nil{
            loadingResponses[url]?.append(completion)
            return
        }else{
            loadingResponses[url] = [completion]
        }
        
        //Fetch from server
        URLSession.shared.dataTask(with: url as URL) { (data, response, error) in
            guard let data = data, let image = UIImage(data: data),
                  let blocks = self.loadingResponses[url], error == nil else {
                completion(cellItem, self.errorImg)
                return
            }
            
            //Save to cache
            self.cachedImages.setObject(image, forKey: cellItem.imageModel.id as NSString, cost: data.count)
            
            //Save to disk
            self.fileManager.saveImage(image: image, imageName: cellItem.imageModel.id, key: cellItem.imageModel.key)
            
            for block in blocks{
                block(cellItem,image)
                return
            }
        }.resume()
    }
}
