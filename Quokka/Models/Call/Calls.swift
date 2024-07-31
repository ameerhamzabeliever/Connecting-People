//
//  Calls.swift
//  Quokka
//
//  Created by Muhammad Zubair on 21/01/2021.
//  Copyright © 2021 Codes Binary. All rights reserved.
//

import UIKit
import SwiftyJSON

struct CallModel {
    let id         : String
    let timeStamp  : String
    let userStatus : String
    let toUser     : UserModel
    
    init(json : JSON) {
        id         = json["_id"]   .stringValue
        timeStamp  = json["time"]  .stringValue
        userStatus = json["status"].stringValue
        toUser     = UserModel(json: json["user"])
    }
}
