//
//  AddRemoveFriendVC.swift
//  Quokka
//
//  Created by Muhammad Zubair on 22/02/2021.
//  Copyright © 2021 Codes Binary. All rights reserved.
//

import UIKit
import SwiftyJSON
import DTOverlayController

class AddRemoveFriendVC: UIViewController {
    
    /* MARK:- OUTLETS */
    /// Buttons
    @IBOutlet weak var btnReportFriend  : UIButton!
    @IBOutlet weak var btnRemoveFriend  : UIButton!
    @IBOutlet weak var btnAddFriend     : UIButton!
    @IBOutlet weak var btnCancelRequest : UIButton!
    @IBOutlet weak var btnAcceptRequest : UIButton!
    @IBOutlet weak var btnRejectRequest : UIButton!
    @IBOutlet weak var btnBlockUser     : UIButton!
    /// Stack View
    @IBOutlet weak var btnAcceptReject  : UIStackView!
    /// Outlet Collections
    @IBOutlet var viewsRoundx6          : [UIView]!
    
    /* MARK:- Properties */
    var userObj    : UserModel?
    var userStatus : String?
    /* MARK:- CLOSURES */
    var didLoadData       : (() -> Void)?
    /* MARK:- LIFE CYCLE */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        didLoadData?()
    }
}
/* MARK:- Methods */
extension AddRemoveFriendVC {
    func setupVC(){
        self.view.minFontSize()
        layoutVC()
        loadData()
    }
    func loadData() {
        if let user = userObj {
            btnReportFriend.setTitle("Report \(user.displayName)", for: .normal)
            btnBlockUser   .setTitle("Block \(user.displayName)", for: .normal)
            switch userStatus {
            case "Add":
                btnRemoveFriend .isHidden = true
                btnAcceptReject .isHidden = true
                btnCancelRequest.isHidden = true
            case "Friends" :
                btnAddFriend    .isHidden = true
                btnAcceptReject .isHidden = true
                btnCancelRequest.isHidden = true
            case "Pending" :
                btnAddFriend    .isHidden = true
                btnRemoveFriend .isHidden = true
                btnAcceptReject .isHidden = true
            case "Accept" :
                btnAddFriend    .isHidden = true
                btnRemoveFriend .isHidden = true
                btnCancelRequest.isHidden = true
            default:
                break
            }
        }
    }
    func layoutVC(){
        MAIN_DISPATCH.async { [self] in
            for v in viewsRoundx6 {
                v.layer.cornerRadius = v.bounds.height / 6
            }
        }
    }
}
/* MARK:- Actions */
extension AddRemoveFriendVC {
    @IBAction func addFriend(_ sender : UIButton ){
        if let user = userObj {
            let id = user.id
            addFriendApi(id)
        }
    }
    @IBAction func removeFriend(_ sender : UIButton ){
        if let user = userObj {
            let id = user.id
            removeFriendApi(id)
        }
    }
    @IBAction func acceptRequest(_ sender : UIButton ){
        if let user = userObj {
            let id = user.id
            acceptFriendApi(id)
        }
    }
    @IBAction func rejectRequest(_ sender : UIButton ){
        if let user = userObj {
            let id = user.id
            let status = "Received"
            cancelRequestApi(id, status)
        }
    }
    @IBAction func cancelRequest(_ sender : UIButton ){
        if let user = userObj {
            let id = user.id
            let status = "Sent"
            cancelRequestApi(id, status)
        }
    }
    @IBAction func blockUser(_ sender : UIButton ){
        if Constants.sharedInstance.isSearching || Constants.sharedInstance.isResponsing || Constants.sharedInstance.isWaiting || Constants.sharedInstance.isAnimating || Constants.sharedInstance.isUserInCall{
            showAlert(message: "You cannot block this user at this time. Please cancel the call first.")
        }
        else{
            self.showAlertDualAction(title: "", message: "Are you sure you want to block \(userObj!.displayName)?") { (completed) in
                if completed {
                    if let user = self.userObj {
                        let id = user.id
                        self.blockUserApi(id)
                    }
                }
            }
        }
    }
    @IBAction func reportUserTapped(_ sender : UIButton ){
        let reportVC = ReportVC(
            nibName : Constants.VCNibs.REPORT_USER,
            bundle  : nil)
        reportVC.userID = userObj!.id
        reportVC.dismissPreviousVC = { [weak self]  in
            self!.dismiss(animated: true, completion: nil)
        }
        let overlayController = DTOverlayController(viewController: reportVC)
        overlayController.overlayViewCornerRadius = 30
        overlayController.overlayHeight = .dynamic(0.75)
        present(overlayController, animated: true, completion: nil)
    }
}
/* MARK:- Api Methods */
extension AddRemoveFriendVC {
    func addFriendApi(_ userID : String){
        if !Reachability.isConnectedToNetwork() {
            self.showToast(message: "No Internet Connection!")
            return
        }
        let param = ["id" : userID]
        self.showSpinner(onView: btnAddFriend , indicatorColor: .black)
        NetworkManager.sharedInstance.addFriend(param: param) { (response) in
            self.removeSpinner()
            switch response.result {
            case .success(_):
                do {
                    let apiData = try JSON(data: response.data!)
                    Helper.debugLogs(any: apiData)
                    let dataObj = apiData["data"]
                    let message = dataObj["message"].stringValue
                    if response.response?.statusCode == 200 {
                        if message == "This User has Already Send You Friend Request" {
                            self.showToast(message: message)
                            MAIN_DISPATCH.asyncAfter(deadline: .now() + 1) {
                                self.dismiss(animated: true, completion: nil)
                            }
                        } else {
                            self.dismiss(animated: true, completion: nil)
                        }
                    } else if response.response?.statusCode == 401 {
                        self.showToast(message: "UnAuthorized : User Not Found")
                        self.logoutUser()
                    } else {
                        self.showToast(message: message)
                    }
                }
                catch {
                    self.showToast(message: response.error?.localizedDescription ?? "Something went wrong")
                }
            case .failure(_):
                self.showToast(message: "Something went wrong with Servers")
            }
        }
    }
    func acceptFriendApi(_ userID : String){
        if !Reachability.isConnectedToNetwork() {
            self.showToast(message: "No Internet Connection!")
            return
        }
        let param = ["id" : userID]
        self.showSpinner(onView: btnAcceptRequest , indicatorColor: .black)
        NetworkManager.sharedInstance.acceptFriend(param: param) { (response) in
            self.removeSpinner()
            switch response.result {
            case .success(_):
                do {
                    let apiData = try JSON(data: response.data!)
                    Helper.debugLogs(any: apiData)
                    let dataObj = apiData["data"]
                    let message = dataObj["message"].stringValue
                    if response.response?.statusCode == 200 {
                        if message == "No Request Found againt this User Id" {
                            self.showToast(message: "Friend Request Already Removed")
                            MAIN_DISPATCH.asyncAfter(deadline: .now() + 1) {
                                self.dismiss(animated: true, completion: nil)
                            }
                        } else {
                            self.dismiss(animated: true, completion: nil)
                        }
                    } else if response.response?.statusCode == 401 {
                        self.showToast(message: "UnAuthorized : User Not Found")
                        self.logoutUser()
                    } else {
                        self.showToast(message: message)
                    }
                }
                catch {
                    self.showToast(message: response.error?.localizedDescription ?? "Something went wrong")
                }
            case .failure(_):
                self.showToast(message: "Something went wrong with Servers")
            }
        }
    }
    func removeFriendApi(_ userID : String){
        if !Reachability.isConnectedToNetwork() {
            self.showToast(message: "No Internet Connection!")
            return
        }
        let param = ["id" : userID]
        self.showSpinner(onView: btnRemoveFriend , indicatorColor: .black)
        NetworkManager.sharedInstance.removeFriend(param: param) { (response) in
            self.removeSpinner()
            switch response.result {
            case .success(_):
                do {
                    let apiData = try JSON(data: response.data!)
                    Helper.debugLogs(any: apiData)
                    let dataObj = apiData["data"]
                    let message = dataObj["message"].stringValue
                    if response.response?.statusCode == 200 {
                        if message == "This User is not in Your Friend List or other Your have unfriend you already" {
                            self.showToast(message: "User already remove you from Friends")
                            MAIN_DISPATCH.asyncAfter(deadline: .now() + 1) {
                                self.dismiss(animated: true, completion: nil)
                            }
                        } else {
                            self.dismiss(animated: true, completion: nil)
                        }
                    } else if response.response?.statusCode == 401 {
                        self.showToast(message: "UnAuthorized : User Not Found")
                        self.logoutUser()
                    } else {
                        self.showToast(message: message)
                    }
                }
                catch {
                    self.showToast(message: response.error?.localizedDescription ?? "Something went wrong")
                }
            case .failure(_):
                self.showToast(message: "Something went wrong with Servers")
            }
        }
    }
    func cancelRequestApi(_ userID : String,_ status : String){
        if !Reachability.isConnectedToNetwork() {
            self.showToast(message: "No Internet Connection!")
            return
        }
        var param : [String : Any] = [:]
        param["id"]   = userID
        param["type"] = status
        if status == "Sent" {
            self.showSpinner(onView: btnCancelRequest , indicatorColor: .black)
        } else {
            self.showSpinner(onView: btnRejectRequest , indicatorColor: .black)
        }
        NetworkManager.sharedInstance.cancelFriend(param: param) { (response) in
            self.removeSpinner()
            switch response.result {
            case .success(_):
                do {
                    let apiData = try JSON(data: response.data!)
                    Helper.debugLogs(any: apiData)
                    let dataObj = apiData["data"]
                    let message = dataObj["message"].stringValue
                    if response.response?.statusCode == 200 {
                        if message == "No Request Found Against This User" {
                            self.showToast(message: "Request is Already Accepted or Rejected")
                            MAIN_DISPATCH.asyncAfter(deadline: .now() + 1) {
                                self.dismiss(animated: true, completion: nil)
                            }
                        } else {
                            self.dismiss(animated: true, completion: nil)
                        }
                    } else if response.response?.statusCode == 401 {
                        self.showToast(message: "UnAuthorized : User Not Found")
                        self.logoutUser()
                    } else {
                        self.showToast(message: message)
                    }
                }
                catch {
                    self.showToast(message: response.error?.localizedDescription ?? "Something went wrong")
                }
            case .failure(_):
                self.showToast(message: "Something went wrong with Servers")
            }
        }
    }
    func blockUserApi(_ userID : String){
        if !Reachability.isConnectedToNetwork() {
            self.showToast(message: "No Internet Connection!")
            return
        }
        let param = ["id" : userID]
        self.showSpinner(onView: btnBlockUser , indicatorColor: .black)
        NetworkManager.sharedInstance.blockUser(param: param) { (response) in
            self.removeSpinner()
            switch response.result {
            case .success(_):
                do {
                    let apiData = try JSON(data: response.data!)
                    Helper.debugLogs(any: apiData)
                    let dataObj = apiData["data"]
                    let message = dataObj["message"].stringValue
                    if response.response?.statusCode == 200 {
                        if message == "You are already Blocked by User" {
                            self.showToast(message: message)
                            MAIN_DISPATCH.asyncAfter(deadline: .now() + 1) {
                                self.dismiss(animated: true, completion: nil)
                            }
                        } else {
                            self.dismiss(animated: true, completion: nil)
                        }
                    } else if response.response?.statusCode == 401 {
                        self.showToast(message: "UnAuthorized : User Not Found")
                        self.logoutUser()
                    } else {
                        self.showToast(message: message)
                    }
                }
                catch {
                    self.showToast(message: response.error?.localizedDescription ?? "Something went wrong")
                }
            case .failure(_):
                self.showToast(message: "Something went wrong with Servers")
            }
        }
    }
}
