//
//  Constants.swift
//  Quokka
//
//  Created by Muhammad Zubair on 19/11/2020.
//  Copyright © 2020 Codes Binary. All rights reserved.
//

import Foundation
import Alamofire

struct Constants {
    /* MARK:- Singleton struct initilization */
    static var sharedInstance : Constants = Constants()
    var isLogout              : Bool    = false
    var isUserInCall          : Bool    = false
    var isWaiting             : Bool    = false
    var isSearching           : Bool    = false
    var isAnimating           : Bool    = false
    var isResponsing          : Bool    = false
    /// Profile VC Reference
    var PROFILE_VC_REFERENCE  : ProfileVC?
    /// Profile User Color
    var selectedColor         : String  = "Green"
    /// Today Call Limit
    var CALL_LIMIT            : Int     = 0
    /// Pause Time After a Call
    var REST_DURATION         : CGFloat = 0
    var httpHeaders           : HTTPHeaders {
        get {
            return [
                "Authorization" : UserDefaults.standard.string(forKey: Constants.userDefaults.HTTP_HEADERS) ?? ""
            ]
        }
    }
    var USER                  : UserModel? {
        get {
            if let user = DEFAULTS.object(
                forKey: Constants.userDefaults.USER
            ) as? Data {
                
                let decoder = JSONDecoder()
                return try! decoder.decode(
                    UserModel.self, from: user
                )
                
            }
            return nil
        } set {
            if let user = newValue {
                let encoder    = JSONEncoder()
                if let encoded = try? encoder.encode(user) {
                    DEFAULTS.set(encoded, forKey: Constants.userDefaults.USER)
                }
            } else {
                DEFAULTS.set(nil, forKey: Constants.userDefaults.USER)
            }
        }
    }
    /// User Total Calls
    var TOTAL_CALLS           : Int {
        get {
            if let totalCalls = DEFAULTS.object(
                forKey: Constants.userDefaults.TOTAL_CALLS
            ) as? Int {
                return totalCalls
            }
            return 0
        } set {
            DEFAULTS.set(newValue, forKey: Constants.userDefaults.TOTAL_CALLS)
        }
    }
    /// User Today Calls
    var TODAY_CALLS           : Int {
        get {
            if let todayCalls = DEFAULTS.object(
                forKey: Constants.userDefaults.TODAY_CALLS
            ) as? Int {
                return todayCalls
            }
            return 0
        } set {
            DEFAULTS.set(newValue, forKey: Constants.userDefaults.TODAY_CALLS)
        }
    }
    /// User Last Call Time
    var LAST_CALL             : String {
        get {
            if let lastCallTime = DEFAULTS.object(
                forKey: Constants.userDefaults.LAST_CALL
            ) as? String {
                return lastCallTime
            }
            return ""
        } set {
            DEFAULTS.set(newValue, forKey: Constants.userDefaults.LAST_CALL)
        }
    }
    /// User Most Used Emojis
    var RECENT_EMOJIS         : [String] {
        get {
            if let recentEmojis = DEFAULTS.object(
                forKey: Constants.userDefaults.RECENT_EMOJIS
            ) as? [String] {
                return recentEmojis
            }
            return []
        } set {
            DEFAULTS.set(newValue, forKey: Constants.userDefaults.RECENT_EMOJIS)
        }
    }
    /// Feedback Questions after Call
    var FEEDBACK_QUESTIONS    : [String] {
        get {
            if let question = DEFAULTS.object(
                forKey: Constants.userDefaults.FEEDBACK_QUESTIONS
            ) as? [String] {
                return question
            }
            return []
        } set {
            DEFAULTS.set(newValue, forKey: Constants.userDefaults.FEEDBACK_QUESTIONS)
        }
    }
    /// Suggestion during Call
    var SUGGESTIONS           : [String] {
        get {
            if let suggestions = DEFAULTS.object(
                forKey: Constants.userDefaults.SUGGESTIONS
            ) as? [String] {
                return suggestions
            }
            return []
        } set {
            DEFAULTS.set(newValue, forKey: Constants.userDefaults.SUGGESTIONS)
        }
    }
    /// User Name
    var USER_NAME           : String {
        get {
            if let userName = DEFAULTS.object(
                forKey: Constants.userDefaults.USER_NAME
            ) as? String {
                return userName
            }
            return ""
        } set {
            DEFAULTS.set(newValue, forKey: Constants.userDefaults.USER_NAME)
        }
    }
    
    /* MARK:- End Points */
    struct endPoints {
        static let LOGIN             = "login"
        static let APPLE_LOGIN       = "apple/login"
        static let GET_PROFILE       = "details"
        static let GET_OTHER_PROFILE = "user/details"
        static let USERNAME          = "check-username"
        static let UPDATE_PROFILE    = "update-profile"
        static let UPDATE_COLOR      = "update-color"
        static let UPDATE_AVATAR     = "update-avatar"
        static let GET_CALLS         = "mycalls"
        static let GET_REVIEWS       = "get-reviews"
        static let SAVE_FEEDBACK     = "save-feedback"
        static let GET_FRIENDS       = "show/friends"
        static let GET_REQUESTS      = "friend/requests"
        static let ADD_FRIEND        = "friend/add"
        static let ACCEPT_FRIEND     = "friend/accept"
        static let CANCEL_REQUEST    = "friend/reject"
        static let REMOVE_FRIEND     = "friend/remove"
        static let UNBLOCK_USER      = "unblock"
        static let BLOCK_USER        = "block"
        static let REPORT_USER       = "report"
        static let UPDATE_EMOJI      = "update-emoji"
        static let GET_SETTINGS      = "settings"
        static let GET_QUESTIONS     = "get-feedback"
        static let GET_SUGGESTIONS   = "convo-staters"
        static let GIVE_REVIEW       = "reviews"
    }
    /* MARK:- View Controllers */
    struct VCNibs {
        static let LAUNCH          = "LauchVC"
        static let LOGIN           = "LoginVC"
        static let HOME            = "HomeVC"
        static let PROFILE         = "ProfileVC"
        static let COLOR           = "ColorVC"
        static let FLAG            = "FlagVC"
        static let FEEDBACK        = "FeedbackVC"
        static let OTHER_PROFILE   = "OtherProfileVC"
        static let SETUP_PROFILE   = "SetupProfileVC"
        static let RECENT_CONVO    = "RecentConvoVC"
        static let FRIENDS         = "FriendsVC"
        static let TROPHIES        = "TrophiesVC"
        static let REVIEWS         = "ReviewsVC"
        static let FRIEND_REQUESTS = "FriendRequestVC"
        static let ADD_REMOVE      = "AddRemoveFriendVC"
        static let REPORT_USER     = "ReportVC"
        static let SETTINGS        = "SettingsVC"
    }
    /* MARK:- Collection View Cells */
    struct CVCELLS {
        static let EMOJI            = "EmojiCell"
        static let PROFILE_QUESTION = "ProfileQuestionCell"
        static let COLOR            = "ColorCell"
    }
    /* MARK:- Table View Cells */
    struct TVCELLS {
        static let CONVO           = "ConvoCell"
        static let FRIEND          = "FriendCell"
        static let REVIEW          = "ReviewCell"
    }
    /* MARK:- User Defaults */
    struct userDefaults {
        static let HTTP_HEADERS       = "httpHeaders"
        static let USER               = "user"
        static let TOTAL_CALLS        = "totalCalls"
        static let TODAY_CALLS        = "todayCalls"
        static let LAST_CALL          = "lastCallTime"
        static let RECENT_EMOJIS      = "recentEmojis"
        static let FEEDBACK_QUESTIONS = "feedbackQuestions"
        static let SUGGESTIONS        = "suggestions"
        static let USER_NAME          = "userName"
    }
}
