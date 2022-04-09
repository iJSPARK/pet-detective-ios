//
//  EmergencyRecuePetInfoController.swift
//  PetDetective
//
//  Created by Junseo Park on 2022/04/07.
//

import Foundation

// URL session으로 api 연동
// 추후 alamofire로 변경 
struct EmergencyRescuePetInfoController {
    func fetchedMissingPetInfo(completion: @escaping (MissingPet?) -> Void) {
          
        let baseUrl = URL(string: "https://iospring.herokuapp.com/detect")!
        
        let query: [String: String] = [
            "page": "2"
        ]
        
        guard let url = baseUrl.withQueries(query) else {
            print("Unalbe to build URL")
            return
        }
        
        let taskObject = URLSession.shared.dataTask(with: url) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            
            if let data = data, let petInfo = try? jsonDecoder.decode(MissingPet.self, from: data) {
                // 응답 처리 로직
                print("Data was returned and data was properly decoded")
                completion(petInfo) // 함수가 끝나고 나면 호출
            } else {
                print("Either no data was returned, or data was not properly decoded")
                completion(nil)
                return
            }
            
        }
        
        taskObject.resume()
    }

}
