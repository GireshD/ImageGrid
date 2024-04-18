//
//  LocalFileManager.swift
//  ImageGrid
//
//  Created by Giresh Dora on 18/04/24.
//

import Foundation
import UIKit

class LocalFileManager{
    
    enum ImageType: String{
        case jpg
        case png
    }
    
    static let shared = LocalFileManager()
    
    private init() {}
    
    final func saveImage(image: UIImage,
                         imageName: String,
                         key: String)
    {
        //Create folder
        createFolderIfNeeded()
        
        //Get file path and image data
        guard let imageData = getImageData(image: image, key: key), let imagePath = getImagePath(imageName: imageName, key: key) else {
            return
        }
        
        //Save image data to disk
        do{
            try imageData.write(to: imagePath)
        }
        catch{
            print("Unable same image name: \(imageName)")
        }
    }
    
    final func getImage(imageName: String,
                        key: String) -> (UIImage?, NSData?)?
    {
        guard let url = getImagePath(imageName: imageName, key: key),
              FileManager.default.fileExists(atPath: url.path) else{
            return nil
        }
        return (UIImage(contentsOfFile: url.path), NSData(contentsOfFile: url.path))
    }
    
    private func createFolderIfNeeded(){
        guard let url = getFolderPath() else {
            return
        }
        if !FileManager.default.fileExists(atPath: url.path){
            
            do{
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            }
            catch{
                print("Error in create folder: \(error.localizedDescription)")
            }
        }
    }
    
    private func getFolderPath() -> URL?{
        guard let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        return url.appending(path: "Coverage_Image")
    }
    
    private func getImagePath(imageName: String,
                              key: String) -> URL?
    {
        guard let url = getFolderPath() else {
            return nil
        }
        return url.appending(path: imageName + "." + getImageType(key: key))
    }
    
    private func getImageType(key: String) -> String{
        guard let imageType = key.components(separatedBy: ".").last else{
            return "png"
        }
        return imageType
    }
    
    private func getImageData(image: UIImage,
                              key: String) -> Data?
    {
        let imageType = getImageType(key: key)
        
        if imageType == ImageType.png.rawValue{
            let imageData = image.pngData()
            return imageData
        }
        else if imageType == ImageType.jpg.rawValue{
            let imageData = image.jpegData(compressionQuality: 0.5)
            return imageData
        }
        
        return nil
    }
}
