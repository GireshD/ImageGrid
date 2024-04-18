//
//  APIManager.swift
//  ImageGrid
//
//  Created by Giresh Dora on 17/04/24.
//

import Foundation


class APIManager{
    
    enum CustomError: Error{
        case invalidUrl
        case invalidData
    }
    
    static let shared: APIManager = APIManager()
    
    private init() {}
    
    final func request<T: Codable>(url: URL?,
                                   expecting:T.Type,
                                   completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = url else {
            completion(.failure(CustomError.invalidUrl))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                if let error = error {
                    completion(.failure(error))
                }else{
                    completion(.failure(CustomError.invalidData))
                }
                return
            }
            
            do{
                let coverages = try JSONDecoder().decode(T.self, from: data)
                
                completion(.success(coverages))
            } catch{
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
