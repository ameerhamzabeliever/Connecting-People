//
//  FriendsVC.swift
//  Quokka
//
//  Created by Muhammad Zubair on 15/01/2021.
//  Copyright © 2021 Codes Binary. All rights reserved.
//

import UIKit
import SwiftyJSON
import SkeletonView
import XLPagerTabStrip
import DTOverlayController

class FriendsVC: UIViewController {
    /* MARK:- OUTLETS */
    /// Buttons
    @IBOutlet weak var btnSeeAll        : UIButton!
    /// Table Views
    @IBOutlet weak var tvAllFriends     : UITableView!
    @IBOutlet weak var tvFriendRequests : UITableView!
    /// Constraints
    @IBOutlet weak var consHeightViewFriends  : NSLayoutConstraint!
    @IBOutlet weak var consHeightViewRequests : NSLayoutConstraint!
    /* MARK:- Properties */
    var profileReference = ProfileVC()
    var currentPage    : Int         = 1
    var totalPages     : Int         = 1
    var isLoading      : Bool        = false
    var apiCalled      : Bool        = false /// Just to show empty message on table view after api is called
    var allFriends     : [UserModel] = []
    var friendRequests : [UserModel] = []
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
extension FriendsVC {
    func setupVC(){
        self.view.minFontSize()
        registerNibs()
    }
    func loadData(){
        self.consHeightViewRequests.constant = self.profileReference.containerView.bounds.height * 0.31
        self.consHeightViewFriends.constant =
            self.profileReference.containerView.bounds.height * 0.69
        currentPage    = 1
        apiCalled      = false
        allFriends     = []
        friendRequests = []
        tvAllFriends    .setContentOffset(.zero, animated: false)
        tvFriendRequests.setContentOffset(.zero, animated: false)
        tvAllFriends    .reloadData()
        tvFriendRequests.reloadData()
        Helper.showTVSkeletonView(tableView: tvAllFriends)
        Helper.showTVSkeletonView(tableView: tvFriendRequests)
        getAllFriends()
    }
    func registerNibs(){
        let friendNib = UINib(nibName: Constants.TVCELLS.FRIEND,bundle: nil)
        tvAllFriends    .register(friendNib, forCellReuseIdentifier: Constants.TVCELLS.FRIEND)
        tvFriendRequests.register(friendNib, forCellReuseIdentifier: Constants.TVCELLS.FRIEND)
    }
}
/* MARK:- OBJ-C Methods */
extension FriendsVC {
    @objc func acceptRequest(_ sender : UIButton) {
        let index  = sender.tag
        let userID = friendRequests[index].id
        acceptFriendApi(userID)
    }
    @objc func callFriend(_ sender : UIButton) {
    }
    @objc func cancelRecieveRequest(_ sender : UIButton) {
        let index  = sender.tag
        let userID = friendRequests[index].id
        cancelRequestApi(userID, "Received")
    }
    @objc func showRequestProfile(_ sender : UIButton) {
        let index  = sender.tag
        let userID = friendRequests[index].id
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
    @objc func showFriendProfile(_ sender : UIButton) {
        let index  = sender.tag
        let userID = allFriends[index].id
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
extension FriendsVC {
    func getAllFriends(){
        if !Reachability.isConnectedToNetwork() {
            self.showToast(message: "No Internet Connection!")
            MAIN_DISPATCH.async {
                self.tvAllFriends   .stopSkeletonAnimation()
                self.tvFriendRequests.stopSkeletonAnimation()
            }
            return
        }
        let param = ["page" : currentPage]
        isLoading = true
        apiCalled = true
        NetworkManager.sharedInstance.getFriends(param: param) { (response) in
            self.isLoading = false
            self.tvAllFriends.tableFooterView = nil
            MAIN_DISPATCH.async {
                self.tvAllFriends    .hideSkeleton()
                self.tvFriendRequests.hideSkeleton()
            }
            switch response.result {
            case .success(_):
                do {
                    let apiData = try JSON(data: response.data!)
                    Helper.debugLogs(any: apiData)
                    let dataObj = apiData["data"]
                    let message = dataObj["message"].stringValue
                    if response.response?.statusCode == 200 {
                        self.totalPages  = dataObj["pages"].intValue
                        let friendsJson  = dataObj["friends"]
                        let requestsJson = dataObj["friendRequests"]
                        let friendsArray = friendsJson.arrayValue.map({UserModel(json: $0)})
                        self.friendRequests = requestsJson.arrayValue.map({UserModel(json: $0["from"])})
                        self.allFriends.append(contentsOf: friendsArray)
                        if self.friendRequests.count > 1 {
                            self.consHeightViewRequests.constant = self.profileReference.containerView.bounds.height * 0.5
                            self.consHeightViewFriends.constant = self.profileReference.containerView.bounds.height * 0.5
                        }
                        self.tvAllFriends.reloadData()
                        self.tvFriendRequests.reloadData()
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
        Helper.showTVSkeletonView(tableView: tvAllFriends)
        Helper.showTVSkeletonView(tableView: tvFriendRequests)
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
    func cancelRequestApi(_ userID : String,_ status : String){
        if !Reachability.isConnectedToNetwork() {
            self.showToast(message: "No Internet Connection!")
            return
        }
        var param : [String : Any] = [:]
        param["id"]   = userID
        param["type"] = status
        Helper.showTVSkeletonView(tableView: tvAllFriends)
        Helper.showTVSkeletonView(tableView: tvFriendRequests)
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
/* MARK:- Actions */
extension FriendsVC {
    @IBAction func seeAllRequests (_ sender : UIButton) {
        let requestVC = FriendRequestVC(
            nibName : Constants.VCNibs.FRIEND_REQUESTS,
            bundle  : nil)
        self.present(requestVC, animated: true, completion: nil)
    }
}
/* MARK:- TableView Delegate and DataSource */
extension FriendsVC : UITableViewDelegate, SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return Constants.TVCELLS.FRIEND
    }
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if skeletonView == tvFriendRequests {
            return 1
        } else {
            return 3
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tvAllFriends {
            if apiCalled {
                if allFriends.count == 0 {
                    tableView.setEmptyMessage("No Friends")
                } else {
                    tableView.restoreEmptyMessage()
                }
            } else {
                tableView.restoreEmptyMessage()
            }
            return allFriends.count
        } else {
            if apiCalled {
                if friendRequests.count == 0 {
                    self.btnSeeAll.alpha = 0.0
                    tableView.setEmptyMessage("No Friend Requests")
                } else {
                    tableView.restoreEmptyMessage()
                }
            } else {
                tableView.restoreEmptyMessage()
            }
            return friendRequests.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let friendCell = tableView.dequeueReusableCell(withIdentifier: Constants.TVCELLS.FRIEND) as! FriendCell
        let row = indexPath.row
        friendCell.btnCall.tag = row
        if tableView == tvAllFriends {
            friendCell.setupCellForFriends(allFriends[row])
            friendCell.btnCall.tag = row
            friendCell.btnCall.addTarget(
                self                                ,
                action : #selector(callFriend(_:)),
                for    : .touchUpInside
            )
            friendCell.btnShowProfile.addTarget(
                self,
                action : #selector(showFriendProfile(_:)),
                for    : .touchUpInside
            )
        } else {
            friendCell.setupCellForRequests(friendRequests[row])
            friendCell.btnAcceptRequest.tag = row
            friendCell.btnCancelRequest.tag = row
            friendCell.btnAcceptRequest.addTarget(
                self                                ,
                action : #selector(acceptRequest(_:)),
                for    : .touchUpInside
            )
            friendCell.btnCancelRequest.addTarget(
                self                                ,
                action : #selector(cancelRecieveRequest(_:)),
                for    : .touchUpInside
            )
            friendCell.btnShowProfile.addTarget(
                self,
                action : #selector(showRequestProfile(_:)),
                for    : .touchUpInside
            )
           
        }
        return friendCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if friendRequests.count <= 1 {
            if tableView == tvFriendRequests {
                return (consHeightViewRequests.constant - 40)
            } else {
                return (consHeightViewFriends.constant - 40) / 3
            }
        } else {
            return consHeightViewFriends.constant / 2
        }
        
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tvAllFriends {
            let position = scrollView.contentOffset.y
            if currentPage < totalPages {
                if position > (tvAllFriends.contentSize.height - 10 - scrollView.frame.size.height) {
                    if isLoading {
                        // we are already fetching data
                        return
                    }
                    currentPage += 1
                    tvAllFriends.tableFooterView = Helper.showLoadingFooter(tvAllFriends, .black)
                    getAllFriends()
                }
            }
            
        }
    }
}
/* MARK:- Pager Info Indicator */
extension FriendsVC :  IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Friends")
    }
}
