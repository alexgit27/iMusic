//
//  NetworkService.swift
//  IMusic
//
//  Created by Alexandr on 27.03.2021.
//

import Foundation
import Alamofire

class NetworkService {
    func fetchTracks(searchText: String, completion: @escaping (SearchResponse?) -> Void) {
        let url = "https://itunes.apple.com/search"
        let parameters = ["term": "\(searchText)", "limit": "100", "media" : "music"]
        AF.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData(completionHandler: { dataResponse in
            if let error = dataResponse.error {
                print(error.localizedDescription)
                completion(nil)
                return
            }
            
            guard let data = dataResponse.data else { return }
            
            let decoder = JSONDecoder()
            do {
                let objects = try decoder.decode(SearchResponse.self, from: data)
                completion(objects)
            } catch {
                print(error.localizedDescription)
                completion(nil)
            }
        })
    }
}
