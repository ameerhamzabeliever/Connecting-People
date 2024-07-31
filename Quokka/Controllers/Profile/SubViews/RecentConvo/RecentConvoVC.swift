//
//  RecentConvoVC.swift
//  Quokka
//
//  Created by Muhammad Zubair on 15/01/2021.
//  Copyright © 2021 Codes Binary. All rights reserved.
//

import UIKit
import SwiftyJSON
import SkeletonView
import DTOverlayController
import XLPagerTabStrip

class RecentConvoVC: UIViewController {
    
    /* MARK:- OUTLETS */
    /// ImageViews
    @IBOutlet weak var imgNoCall    : UIImageView!
    /// TableView
    @IBOutlet weak var tvRecenCalls : UITableView!
    
    /* MARK:- Properties */
    var currentPage : Int         = 1
    var totalPages  : Int         = 1
    var apiCalled   : Bool        = false /// Just to show empty message on table view after api is called
    var isLoading   : Bool        = false
    var allCalls    : [CallModel] = []
    /* MARK:- Life Cycle */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadData()
    }
}
/* MARK:- Methods */
extension RecentConvoVC {
    func setupVC(){
        registerNibs()
    }
    func loadData(){
        currentPage = 1
        apiCalled   = false
        allCalls    = []
        tvRecenCalls.setContentOffset(.zero, animated: false)
        tvRecenCalls.reloadData()
        Helper.showTVSkeletonView(tableView: tvRecenCalls)
        getAllCalls()
    }
    func registerNibs(){
        let convoNib = UINib(nibName: Constants.TVCELLS.CONVO,bundle: nil)
        tvRecenCalls.register(convoNib, forCellReuseIdentifier: Constants.TVCELLS.CONVO)
    }
}

/* MARK:- OBJ-C Methods */
extension RecentConvoVC {
    @objc func addFriend(_ sender : UIButton) {
        let index  = sender.tag
        let userID = allCalls[index].toUser.id
        addFriendApi(userID)
    }
    @objc func acceptRequest(_ sender : UIButton) {
        let index  = sender.tag
        let userID = allCalls[index].toUser.id
        acceptFriendApi(userID)
    }
    @objc func cancelRecieveRequest(_ sender : UIButton) {
        let index  = sender.tag
        let userID = allCalls[index].toUser.id
        cancelRequestApi(userID, "Received")
    }
    @objc func cancelSentRequest(_ sender : UIButton) {
        let index  = sender.tag
        let userID = allCalls[index].toUser.id
        cancelRequestApi(userID, "Sent")
    }
    @objc func unblockUser(_ sender : UIButton) {
        let index  = sender.tag
        let userID = allCalls[index].toUser.id
        unblockUserApi(userID)
    }
    @objc func showFriendProfile(_ sender : UIButton) {
        let index  = sender.tag
        let userID = allCalls[index].toUser.id
        let otherProfileVC = OtherProfileVC(
            nibName : Constants.VCNibs.OTHER_PROFILE,
            bundle  : nil)
        otherProfileVC.userID      = userID
        otherProfileVC.didLoadData = { [weak self] () in
            self!.loadData()
        }
        let overlayController = DTOverlayController(viewController: otherProfileVC)
        overlayController.overlayViewCornerRadius = 30
        overlayController.overlayHeight = .dynamic(0.95)
        present(overlayController, animated: true, completion: nil)
        
    }
}

/* MARK:- Api Methods */
extension RecentConvoVC {
    func getAllCalls(){
        if !Reachability.isConnectedToNetwork() {
            self.showToast(message: "No Internet Connection!")
            MAIN_DISPATCH.async {
                self.tvRecenCalls.stopSkeletonAnimation()
            }
            return
        }
        apiCalled = true
        let param = ["page" : currentPage]
        isLoading = true
        NetworkManager.sharedInstance.getAllCalls(param: param) { (response) in
            self.isLoading = false
            self.tvRecenCalls.tableFooterView = nil
            MAIN_DISPATCH.async {
                self.tvRecenCalls.hideSkeleton()
            }
            switch response.result {
            case .success(_):
                do {
                    let apiData = try JSON(data: response.data!)
                    Helper.debugLogs(any: apiData)
                    let dataObj = apiData["data"]
                    let message = dataObj["message"].stringValue
                    if response.response?.statusCode == 200 {
                        self.totalPages = dataObj["pages"].intValue
                        let callsJson   = dataObj["myCalls"]
                        let calls       = callsJson.arrayValue.map({CallModel(json: $0)})
                        self.allCalls    .append(contentsOf: calls)
                        self.tvRecenCalls.reloadData()
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
    func addFriendApi(_ userID : String){
        if !Reachability.isConnectedToNetwork() {
            self.showToast(message: "No Internet Connection!")
            return
        }
        
        let param = ["id" : userID]
        Helper.showTVSkeletonView(tableView: tvRecenCalls)
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
                        }
                        self.loadData()
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
        Helper.showTVSkeletonView(tableView: tvRecenCalls)
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
                        let message = apiData["data"]["message"].stringValue
                        if message == "No Request Found againt this User Id" {
                            self.showToast(message: "Friend Request Already Removed")
                        }
                        self.loadData()
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
    func unblockUserApi(_ userID : String){
        if !Reachability.isConnectedToNetwork() {
            self.showToast(message: "No Internet Connection!")
            return
        }
        let param = ["id" : userID]
        Helper.showTVSkeletonView(tableView: tvRecenCalls)
        NetworkManager.sharedInstance.unblockUser(param: param) { (response) in
            self.removeSpinner()
            switch response.result {
            case .success(_):
                do {
                    let apiData = try JSON(data: response.data!)
                    Helper.debugLogs(any: apiData)
                    let dataObj = apiData["data"]
                    let message = dataObj["message"].stringValue
                    if response.response?.statusCode == 200 {
                        self.loadData()
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
        Helper.showTVSkeletonView(tableView: tvRecenCalls)
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
                        let message = apiData["data"]["message"].stringValue
                        if message == "No Request Found Against This User" {
                            self.showToast(message: "Request is Already Accepted or Rejected")
                        }
                        self.loadData()
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
/* MARK:- TableView Delegate and DataSource */
extension RecentConvoVC : UITableViewDelegate, SkeletonTableViewDataSource {
    /// Skelton View Data Source
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return Constants.TVCELLS.CONVO
    }
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    /// Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if apiCalled {
            if allCalls.count == 0 {
                imgNoCall.alpha = 1.0
            } else {
                imgNoCall.alpha = 0.0
            }
        } else {
            imgNoCall.alpha = 0.0
        }
        return allCalls.count
    }
    /// Table View Delegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let convoCell = tableView.dequeueReusableCell(withIdentifier: Constants.TVCELLS.CONVO) as! ConvoCell
        let row = indexPath.row
        convoCell.btnAddFriend    .tag = row
        convoCell.btnCall         .tag = row
        convoCell.btnAcceptRequest.tag = row
        convoCell.btnCancelRequest.tag = row
        convoCell.btnCancelPending.tag = row
        convoCell.btnShowProfile  .tag = row
        convoCell.btnUnBlock      .tag = row
        convoCell.btnAcceptRequest.addTarget(
            self                             ,
            action : #selector(acceptRequest(_:)),
            for    : .touchUpInside
        )
        convoCell.btnAddFriend.addTarget(
            self                             ,
            action : #selector(addFriend(_:)),
            for    : .touchUpInside
        )
        convoCell.btnCancelPending.addTarget(
            self                             ,
            action : #selector(cancelSentRequest(_:)),
            for    : .touchUpInside
        )
        convoCell.btnCancelRequest.addTarget(
            self                             ,
            action : #selector(cancelRecieveRequest(_:)),
            for    : .touchUpInside
        )
        convoCell.btnShowProfile.addTarget(
            self                             ,
            action : #selector(showFriendProfile(_:)),
            for    : .touchUpInside
        )
        convoCell.btnUnBlock.addTarget(
            self                             ,
            action : #selector(unblockUser(_:)),
            for    : .touchUpInside
        )
        convoCell.setupCellForCalls(allCalls[row])
        return convoCell
    }
    /// Table View Layout
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tvRecenCalls.bounds.height / 5
    }
    /// Scroll View Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if currentPage < totalPages {
            if position > (tvRecenCalls.contentSize.height - 10 - scrollView.frame.size.height) {
                if isLoading {
                    // we are already fetching data
                    return
                }
                currentPage += 1
                tvRecenCalls.tableFooterView = Helper.showLoadingFooter(tvRecenCalls, .black)
                getAllCalls()
            }
        }
    }
}
/* MARK:- Pager Info Indicator */
extension RecentConvoVC :  IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Recent Convos")
    }
}
