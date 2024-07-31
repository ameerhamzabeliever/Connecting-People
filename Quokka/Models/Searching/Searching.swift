//
//  SearchingModel.swift
//  Quokka
//
//  Created by Hamza's Mac on 03/04/2021.
//  Copyright © 2021 Codes Binary. All rights reserved.
//

import Foundation
import SwiftyJSON

struct SearchingModel {
    let channelName    : String
    let uid            : String
    let emoji          : String
    let avatar         : String
    let name           : String
    let unique_id      : String
    let _id            : String
    
    init(json : JSON) {
        channelName = json["channelName"]      .stringValue
        uid         = json["uid"]              .stringValue
        emoji       = json["user"]["emoji"]    .stringValue
        avatar      = json["user"]["avatar"]   .stringValue
        name        = json["user"]["name"]     .stringValue
        unique_id   = json["user"]["unique_id"].stringValue
        _id         = json["user"]["_id"]      .stringValue
    }
}
