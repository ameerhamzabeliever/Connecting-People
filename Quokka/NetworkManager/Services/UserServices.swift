//
//  UserServices.swift
//  Quokka
//
//  Created by Muhammad Zubair on 28/12/2020.
//  Copyright © 2020 Codes Binary. All rights reserved.
//

import Alamofire

extension NetworkManager {

    func logIn(
        param       : [String:Any],
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        Helper.debugLogs(any: param, and: "LOGIN PARAM")
        sendPostRequest(
            endPoint   : Constants.endPoints.LOGIN,
            parameters : param,
            completion : completion
        )
    }
    func logIn_Apple(
        param: [String: Any],
        completion  : @escaping (DataResponse<String>) -> ()
    ){
        Helper.debugLogs(any: param, and: "APPLE LOGIN PARAM")
        sendPostRequest(
            endPoint   : Constants.endPoints.APPLE_LOGIN,
            parameters : param,
            completion : completion
        )
    }
    func checkUsername(
        param       : [String:Any],
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        Helper.debugLogs(any: param, and: "USERNAME PARAM")
        sendPostRequest(
            endPoint   : Constants.endPoints.USERNAME,
            parameters : param,
            completion : completion
        )
    }
    func updateProfile(
        param       : [String:Any],
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        Helper.debugLogs(any: param, and: "UPDATE PROFILE PARAM")
        sendPostRequestHeaders(
            endPoint   : Constants.endPoints.UPDATE_PROFILE,
            parameters : param,
            completion: completion
        )
    }
    func updateAvatar(
        param       : [String:Any],
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        Helper.debugLogs(any: param, and: "UPDATE AVATAR PARAM")
        sendPostRequestHeaders(
            endPoint   : Constants.endPoints.UPDATE_AVATAR,
            parameters : param,
            completion: completion
        )
    }
    func updateColor(
        param       : [String:Any],
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        Helper.debugLogs(any: param, and: "UPDATE COLOR PARAM")
        sendPostRequestHeaders(
            endPoint   : Constants.endPoints.UPDATE_COLOR,
            parameters : param,
            completion: completion
        )
    }
    func getMyProfile(
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        sendGetRequestHeaders(
            endPoint   : Constants.endPoints.GET_PROFILE,
            completion: completion
        )
    }
    func getOtherUserProfile(
        param       : [String:Any],
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        Helper.debugLogs(any: param, and: "OTHER USER PARAM")
        sendPostRequestHeaders(
            endPoint   : Constants.endPoints.GET_OTHER_PROFILE,
            parameters : param,
            completion: completion
        )
    }
    func updateUserEmoji(
        param       : [String:Any],
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        Helper.debugLogs(any: param, and: "UPDATE EMOJI PARAM")
        sendPostRequestHeaders(
            endPoint   : Constants.endPoints.UPDATE_EMOJI,
            parameters : param,
            completion: completion
        )
    }
}
