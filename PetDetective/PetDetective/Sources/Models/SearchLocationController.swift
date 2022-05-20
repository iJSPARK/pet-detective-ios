//
//  SearchLocationController.swift
//  PetDetective
//
//  Created by Junseo Park on 2022/05/20.
//

import Foundation

struct SearchLocationController {
    func fetchedUserSearchLocation(completion: @escaping (SearchLocation?) -> Void) {
        // http는 info.plist > app transport security setting > allow arbitray loads
        let baseUrl = URL(string: "https://iospring.herokuapp.com/")!
        
        let userId = 74 // interim
        
        let query: [String: String] = [
            "userId": "\(userId)"
        ]
        
        guard let url = baseUrl.withQueries(query) else {
            print("Unalbe to build URL")
            return
        }
        
        let taskObject = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            
            let jsonDecoder = JSONDecoder()
            
            if let data = data, let searchLocation = try? jsonDecoder.decode(SearchLocation.self, from: data) {
                // 응답 처리 로직
                print("Data was returned and data was properly decoded")
                completion(searchLocation) // 함수가 끝나고 나면 호출
            } else {
                print("Either no data was returned, or data was not properly decoded")
                completion(nil)
                return
            }
        }
        
        taskObject.resume()
    }
}
