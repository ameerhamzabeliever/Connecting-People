//
//  CallsServices.swift
//  Quokka
//
//  Created by Muhammad Zubair on 26/01/2021.
//  Copyright © 2021 Codes Binary. All rights reserved.
//

import Alamofire

extension NetworkManager {
    func getAllCalls(
        param       : [String:Any],
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        Helper.debugLogs(any: param, and: "CALLS PARAM")
        sendPostRequestHeaders(
            endPoint   : Constants.endPoints.GET_CALLS,
            parameters : param,
            completion: completion
        )
    }
    func getGlobalSettings(
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        sendGetRequest(
            endPoint    : Constants.endPoints.GET_SETTINGS,
            completion  : completion
        )
    }
    func getFeedbackQuestions(
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        sendGetRequest(
            endPoint    : Constants.endPoints.GET_QUESTIONS,
            completion  : completion
        )
    }
    func getSuggestions(
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        sendGetRequest(
            endPoint    : Constants.endPoints.GET_SUGGESTIONS,
            completion  : completion
        )
    }
}
