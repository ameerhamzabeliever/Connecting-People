//
//  FriendsServices.swift
//  Quokka
//
//  Created by Muhammad Zubair on 26/01/2021.
//  Copyright © 2021 Codes Binary. All rights reserved.
//

import Alamofire

extension NetworkManager {
    
    func getFriends(
        param       : [String:Any],
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        Helper.debugLogs(any: param, and: "FRIENDS PARAM")
        sendPostRequestHeaders(
            endPoint   : Constants.endPoints.GET_FRIENDS,
            parameters : param,
            completion: completion
        )
    }
    func getRequests(
        param       : [String:Any],
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        Helper.debugLogs(any: param, and: "REQUESTS PARAM")
        sendPostRequestHeaders(
            endPoint   : Constants.endPoints.GET_REQUESTS,
            parameters : param,
            completion: completion
        )
    }
    func addFriend(
        param       : [String:Any],
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        Helper.debugLogs(any: param, and: "ADD FRIENDS PARAM")
        sendPostRequestHeaders(
            endPoint   : Constants.endPoints.ADD_FRIEND,
            parameters : param,
            completion: completion
        )
    }
    func acceptFriend(
        param       : [String:Any],
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        Helper.debugLogs(any: param, and: "ACCEPT FRIENDS PARAM")
        sendPostRequestHeaders(
            endPoint   : Constants.endPoints.ACCEPT_FRIEND,
            parameters : param,
            completion: completion
        )
    }
    func cancelFriend(
        param       : [String:Any],
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        Helper.debugLogs(any: param, and: "CANCEL FRIEND PARAM")
        sendPostRequestHeaders(
            endPoint   : Constants.endPoints.CANCEL_REQUEST,
            parameters : param,
            completion: completion
        )
    }
    func removeFriend(
        param       : [String:Any],
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        Helper.debugLogs(any: param, and: "REMOVE FRIEND PARAM")
        sendPostRequestHeaders(
            endPoint   : Constants.endPoints.REMOVE_FRIEND,
            parameters : param,
            completion: completion
        )
    }
    func unblockUser(
        param       : [String:Any],
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        Helper.debugLogs(any: param, and: "UNBLOCK USER PARAM")
        sendPostRequestHeaders(
            endPoint   : Constants.endPoints.UNBLOCK_USER,
            parameters : param,
            completion: completion
        )
    }
    func blockUser(
        param       : [String:Any],
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        Helper.debugLogs(any: param, and: "BLOCK USER PARAM")
        sendPostRequestHeaders(
            endPoint   : Constants.endPoints.BLOCK_USER,
            parameters : param,
            completion: completion
        )
    }
    func reportUser(
        param       : [String:Any],
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        Helper.debugLogs(any: param, and: "BLOCK USER PARAM")
        sendPostRequestHeaders(
            endPoint   : Constants.endPoints.REPORT_USER,
            parameters : param,
            completion: completion
        )
    }
    func getAllReviews(
        param       : [String:Any],
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        Helper.debugLogs(any: param, and: "REVIEWS PARAM")
        sendPostRequestHeaders(
            endPoint   : Constants.endPoints.GET_REVIEWS,
            parameters : param,
            completion: completion
        )
    }
    func saveFeedback( param       : [String:Any],
                       completion  : @escaping (DataResponse<String>) -> ()
    ){
        Helper.debugLogs(any: param, and: "SAVE FEEDBACK")
        sendPostRequestHeaders(endPoint: Constants.endPoints.SAVE_FEEDBACK,
                               parameters: param,
                               completion: completion)
    }
    func giveReview( param       : [String:Any],
                       completion  : @escaping (DataResponse<String>) -> ()
    ){
        Helper.debugLogs(any: param, and: "GIVE REVIEW")
        sendPostRequestHeaders(endPoint: Constants.endPoints.GIVE_REVIEW,
                               parameters: param,
                               completion: completion)
    }
}
