//
//  APICodable.swift
//  PetDetective
//
//  Created by 고석준 on 2022/04/04.
//

import Foundation

class ReportBoard: Codable{
    let mainImageUrl: String?
    let missingLocation: String?
    let id: Int?
    let money: Int?
    let missingLatitude: Double?
    let missingLongitude: Double?
    let missingTime: String?
}

//"mainImageUrl":"https://iospring.s3.ap-northeast-2.amazonaws.com/7c4cf621-1600-4043-8418-1826da262de2.png",
//"missingLocation":"서울광진구",
//"id":4,
//"money":1000,
//"missingLatitude":126.95125920012096,
//"missingLongitude":37.65504092130379,
//"missingTime":"2022-03-31 05:21:46 +0000"


class APIDetectBoardResponse<T: Codable> : Codable {
    var totalPage: Int?
    var detectBoardDTOList: T?
}

