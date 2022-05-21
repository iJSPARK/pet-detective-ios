//
//  SearchLocation.swift
//  PetDetective
//
//  Created by Junseo Park on 2022/05/20.
//

import Foundation

struct UserLocationDto: Codable {
    
//    let phoneNumber: String?
//    let searchLocation: String?
//    let searchLatitude: Double?
//    let searchLongitude: Double?
    
    let phoneNumber: String
    let loadAddress: String
    let latitude: Double
    let longitude: Double
    
//    // key 대칭
//    enum Codingkeys: String, CodingKey {
//        case phoneNumber
//        case searchLocation = "loadAddress"
//        case searchLatitude = "latitude"
//        case searchLongitude = "longitude"
//    }
//
//    init(from decoder: Decoder) throws {
//        // valueContainer: 중간단계 값,
//        let valueContainer = try decoder.container(keyedBy: Codingkeys.self) // enum 타입을 넣어줌
//        self.phoneNumber = try? valueContainer.decode(String.self, forKey: Codingkeys.phoneNumber)
//        self.searchLocation = try? valueContainer.decode(String.self, forKey: Codingkeys.searchLocation)
//        self.searchLatitude = try? valueContainer.decode(Double.self, forKey: Codingkeys.searchLatitude)
//        self.searchLongitude = try? valueContainer.decode(Double.self, forKey: Codingkeys.searchLongitude)
//    }
}

