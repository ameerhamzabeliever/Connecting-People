//
//  NetworkManager.swift
//  Quokka
//
//  Created by Muhammad Zubair on 28/12/2020.
//  Copyright © 2020 Codes Binary. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON

class NetworkManager {
    
    static let sharedInstance = NetworkManager()
    
    func sendGetRequest(
        endPoint: String,
        completion: @escaping (DataResponse<String>) -> Void
    ) -> Void {
        Alamofire.request(
            SERVER_ENV[ENV]! + endPoint,
            method: .get
        ).responseString { response in
            completion(response)
        }
    }
    func sendGetRequestHeaders(
        endPoint: String,
        completion: @escaping (DataResponse<String>) -> Void
    ) -> Void {
        let headers = Constants.sharedInstance.httpHeaders
        Helper.debugLogs(
            any: headers,
            and: "HTTP HEADERS"
        )
        Alamofire.request(
            SERVER_ENV[ENV]! + endPoint,
            method  : .get,
            headers : headers
        ).responseString { response in
            completion(response)
        }
    }
    
    func sendPostRequest(
        endPoint    : String,
        parameters  : Parameters,
        completion  : @escaping (DataResponse<String>) -> Void
    ){
        Alamofire.request(
            SERVER_ENV[ENV]! + endPoint,
            method      : .post,
            parameters  : parameters,
            encoding    : URLEncoding.default
        ).responseString { (response) in
            completion(response)
        }
    }
    
    func sendPostRequestHeaders(
        endPoint    : String,
        parameters  : Parameters,
        completion  : @escaping (DataResponse<String>) -> Void
    ){
        let headers = Constants.sharedInstance.httpHeaders
        Helper.debugLogs(
            any: headers,
            and: "HTTP HEADERS"
        )
        Alamofire.request(
            SERVER_ENV[ENV]! + endPoint,
            method      : .post,
            parameters  : parameters,
            encoding    : URLEncoding.default,
            headers     : headers
        ).responseString { (response) in
            completion(response)
        }
    }
}
