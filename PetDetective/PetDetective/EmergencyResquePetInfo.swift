//
//  EmergencyResquePetInfo.swift
//  PetDetective
//
//  Created by Junseo Park on 2022/04/07.
//

import Foundation

struct MissingPet: Codable {
    let missingPetInfos: [MissingPetInfo]?
    let totalPage: Int?
    
    // key 대칭
    enum Codingkeys: String, CodingKey {
        case missingPetInfos = "detectBoardDTOList"
        case totalPage

    }

    init(from decoder: Decoder) throws {
        // valueContainer: 중간단계 값,
        let valueContainer = try decoder.container(keyedBy: Codingkeys.self) // enum 타입을 넣어줌
        self.missingPetInfos = try? valueContainer.decode([MissingPetInfo].self, forKey: Codingkeys.missingPetInfos)
        self.totalPage = try? valueContainer.decode(Int.self, forKey: Codingkeys.totalPage)
    }
}


struct MissingPetInfo: Codable {
    let image: String?
    let location: String?
    let id: Int?
    let money: Int?
    let latitude: Double?
    let longtitude: Double?
    let missingTime: String?
    
    // key 대칭
    enum Codingkeys: String, CodingKey {
        case image = "mainImageUrl"
        case location = "missingLocation"
        case id
        case money
        case latitude = "missingLongitude"
        case longtitude = "missingLatitude"
        case missingTime
    }

    // JSON파일 Swift 오브젝트로 변환 (decode) 할때 실패할수 있는 함수 있므로 throws init 필요 (중간에 개입 할수 잇게 함)
    // 변환시 KeyedDecodingContainer 중간단계 결과물
    init(from decoder: Decoder) throws {
        // valueContainer: 중간단계 값,
        let valueContainer = try decoder.container(keyedBy: Codingkeys.self) // enum 타입을 넣어줌
        self.image = try? valueContainer.decode(String.self, forKey: Codingkeys.image)
        self.location = try? valueContainer.decode(String.self, forKey: Codingkeys.location)
        self.id = try? valueContainer.decode(Int.self, forKey: Codingkeys.id)
        self.money = try? valueContainer.decode(Int.self, forKey: Codingkeys.money)
        self.latitude = try? valueContainer.decode(Double.self, forKey: Codingkeys.latitude)
        self.longtitude = try? valueContainer.decode(Double.self, forKey: Codingkeys.longtitude)
        self.missingTime = try? valueContainer.decode(String.self, forKey: Codingkeys.missingTime)
    }
    
}
