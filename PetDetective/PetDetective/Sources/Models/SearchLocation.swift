//
//  SearchLocation.swift
//  PetDetective
//
//  Created by Junseo Park on 2022/05/20.
//

import Foundation

struct SearchLocation: Codable {
    var searchLatitude: Double?
    var searchLongitude: Double?
    
    // key 대칭
    enum Codingkeys: String, CodingKey {
        case searchLatitude
        case searchLongitude
    }
    
    init(from decoder: Decoder) throws {
        // valueContainer: 중간단계 값,
        let valueContainer = try decoder.container(keyedBy: Codingkeys.self) // enum 타입을 넣어줌
        self.searchLatitude = try? valueContainer.decode(Double.self, forKey: Codingkeys.searchLatitude)
        self.searchLongitude = try? valueContainer.decode(Double.self, forKey: Codingkeys.searchLongitude)
    }
}

