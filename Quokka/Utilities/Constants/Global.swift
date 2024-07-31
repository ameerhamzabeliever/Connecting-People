//
//  Global.swift
//  Quokka
//
//  Created by Muhammad Zubair on 19/11/2020.
//  Copyright © 2020 Codes Binary. All rights reserved.
//

import Foundation
import UIKit
import SocketIO

/* MARK:- Constants */
let AGORA_APP_ID      = "caa72acc3fed4919bde1f5b0b6cd6309"
var SPINNERS          : [UIView] = []
let PLACEHOLDER_IMAGE = UIImage(named: "placeholder")
let PLACEHOLDER_USER  = UIImage(named: "user-Placeholder")
let APP_NAME          = "Quokka App"
let SCREEN_WIDTH      = UIScreen.main.bounds.width
let SCREEN_HEIGHT     = UIScreen.main.bounds.height
var KEYBOARD_HEIGHT   : CGFloat = 0.0
let MAIN_DISPATCH     = DispatchQueue.main
let DEFAULTS          = UserDefaults.standard
let QUESTIONS         : [String] = [
    "My dream dinner guests are...",
    "My 3rd grade teacher described me as a...",
    "Two truths and a lie"
]
let QUESTION_SUGGESTIONS  : [String] = [
    "Who are they?",
    "Be Honest...",
    "Which one is at..."
]
let PROFILE_COLORS_DICT : [String : UIColor] = ["Mustard"  : #colorLiteral(red: 0.7764705882, green: 0.4901960784, blue: 0.3921568627, alpha: 1) ,
                                                "Green"    : #colorLiteral(red: 0.2392156863, green: 0.4705882353, blue: 0.431372549, alpha: 1) ,
                                                "DarkRed"  : #colorLiteral(red: 0.537254902, green: 0.02352941176, blue: 0.1254901961, alpha: 1) ,
                                                "Blue"     : #colorLiteral(red: 0.231372549, green: 0.3098039216, blue: 0.6117647059, alpha: 1) ,
                                                "DarkGrey" : #colorLiteral(red: 0.1843137255, green: 0.1960784314, blue: 0.2392156863, alpha: 1) ,
                                                "Purple"   : #colorLiteral(red: 0.3568627451, green: 0.2745098039, blue: 0.6235294118, alpha: 1) ,
                                                "Yellow"   : #colorLiteral(red: 0.8235294118, green: 0.6549019608, blue: 0.231372549, alpha: 1) ,
                                                "Red"      : #colorLiteral(red: 0.6431372549, green: 0.05490196078, blue: 0.2980392157, alpha: 1) ]
let PROFILE_COLORS   : [ProfileColor] = [ProfileColor(#colorLiteral(red: 0.7764705882, green: 0.4901960784, blue: 0.3921568627, alpha: 1) , "Mustard" ),
                                         ProfileColor(#colorLiteral(red: 0.2392156863, green: 0.4705882353, blue: 0.431372549, alpha: 1) , "Green"   ),
                                         ProfileColor(#colorLiteral(red: 0.537254902, green: 0.02352941176, blue: 0.1254901961, alpha: 1) , "DarkRed" ),
                                         ProfileColor(#colorLiteral(red: 0.231372549, green: 0.3098039216, blue: 0.6117647059, alpha: 1) , "Blue"    ),
                                         ProfileColor(#colorLiteral(red: 0.1843137255, green: 0.1960784314, blue: 0.2392156863, alpha: 1) , "DarkGrey"),
                                         ProfileColor(#colorLiteral(red: 0.3568627451, green: 0.2745098039, blue: 0.6235294118, alpha: 1) , "Purple"  ),
                                         ProfileColor(#colorLiteral(red: 0.8235294118, green: 0.6549019608, blue: 0.231372549, alpha: 1) , "Yellow"  ),
                                         ProfileColor(#colorLiteral(red: 0.6431372549, green: 0.05490196078, blue: 0.2980392157, alpha: 1) , "Red"     )]

/* MARK:- Storyboards */
let MAIN_STORYBOARD : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

/* MARK:- Socket Enviornment*/
let manager = SocketManager(socketURL: URL(string: SERVER_ENV[ENV]!)!, config: [.log(true), .compress])

/* MARK:- Application ENV */
let ENV = "production"
let SERVER_ENV = [
    "production" : "http://3.135.210.116/api/",
    "staging"    : "https://quokka-back.codesbinary.website/api/",
    "local"      : "http://192.168.10.4:8000/api/"
]
let IMAGES_ENV = [
    "staging"     : "",
    "production"  : ""
]
