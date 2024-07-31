//
//  Review.swift
//  Quokka
//
//  Created by Muhammad Zubair on 16/02/2021.
//  Copyright © 2021 Codes Binary. All rights reserved.
//

import SwiftyJSON

struct ReviewModel : Codable {
    let id             : String
    let reviewText     : String
    let userObj        : UserModelMinified
    let timeStamp      : String
    init(json : JSON) {
        id                       = json["_id"]   .stringValue
        reviewText               = json["review"].stringValue
        userObj                  = UserModelMinified(json: json["from"])
        let dateString           = json["date"].stringValue
        let dateFormatter        = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let myDate               = dateFormatter.date(from: dateString)
        dateFormatter.dateFormat = "MMM d, h:mm a"
        timeStamp                = dateFormatter.string(from: myDate ?? Date())
    }
}
