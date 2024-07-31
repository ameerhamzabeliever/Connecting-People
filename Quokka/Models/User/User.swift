//
//  User.swift
//  Quokka
//
//  Created by Muhammad Zubair on 28/12/2020.
//  Copyright © 2020 Codes Binary. All rights reserved.
//
import SwiftyJSON
import UIKit

struct UserModel : Codable {
    let id             : String
    let displayName    : String
    let userName       : String
    let socialId       : String
    let avatarUrl      : String
    let emoji          : String
    let color          : String
    let age            : String
    let profileAnswers : [String]
    let friends        : [UserModelMinified]
    let reviews        : [ReviewModel]
    
    init(json : JSON) {
        id             = json["_id"]            .stringValue
        displayName    = json["name"]           .stringValue
        userName       = json["userName"]       .stringValue
        socialId       = json["unique_id"]      .stringValue
        avatarUrl      = json["avatar"]         .stringValue
        emoji          = json["emoji"]          .stringValue
        color          = json["color"]          .stringValue
        age            = json["age"]            .stringValue
        profileAnswers = json["profile_answers"].arrayValue.map({$0.stringValue})
        friends        = json["friends"].arrayValue.map({UserModelMinified(json: $0)})
        reviews        = json["reviews"].arrayValue.map({ReviewModel(json: $0)})
    }
}

struct UserModelMinified : Codable {
    let id             : String
    let displayName    : String
    let userName       : String
    let socialId       : String
    let avatarUrl      : String
    
    init(json : JSON) {
        id             = json["_id"]            .stringValue
        displayName    = json["name"]           .stringValue
        userName       = json["userName"]       .stringValue
        socialId       = json["unique_id"]      .stringValue
        avatarUrl      = json["avatar"]         .stringValue
    }
}

