//
//  FriendRequestVC.swift
//  Quokka
//
//  Created by Muhammad Zubair on 27/01/2021.
//  Copyright © 2021 Codes Binary. All rights reserved.
//

import UIKit
import SkeletonView
import SwiftyJSON

class FriendRequestVC: UIViewController {
    
    /* MARK:- OUTLETS */
    /// TableViews
    @IBOutlet weak var tvFriendRequests : UITableView!
    
    /* MARK:- PROPERTIES */
    var allRequests : [UserModel] = []
    var currentPage : Int         = 1
    var totalPages  : Int         = 1
    var isLoading   : Bool        = false
    var apiCalled   : Bool        = false /// Just to show empty message on table view after api is called
    /* MARK:- LifeCycle */
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
extension FriendRequestVC {
    func setupVC(){
        self.view.minFontSize()
        registerNibs()
    }
    func loadData(){
        currentPage    = 1
        apiCalled      = false
        allRequests    = []
        tvFriendRequests.setContentOffset(.zero, animated: false)
        tvFriendRequests.reloadData()
        Helper.showTVSkeletonView(tableView: tvFriendRequests)
        getAllRequests()
    }
    func registerNibs(){
        let friendNib = UINib(nibName: Constants.TVCELLS.FRIEND,bundle: nil)
        tvFriendRequests.register(friendNib, forCellReuseIdentifier: Constants.TVCELLS.FRIEND)
    }
}
/* MARK:- Actions */
extension FriendRequestVC {
    @IBAction func backTapped(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
}
/* MARK:- OBJ-C Methods */
extension FriendRequestVC {
    @objc func acceptRequest(_ sender : UIButton) {
        let index  = sender.tag
        let userID = allRequests[index].id
        acceptFriendApi(userID)
    }
    @objc func cancelRecieveRequest(_ sender : UIButton) {
        let index  = sender.tag
        let userID = allRequests[index].id
        cancelRequestApi(userID, "Received")
    }
}
/* MARK:- Api Methods */
extension FriendRequestVC {
    func getAllRequests(){
        if !Reachability.isConnectedToNetwork() {
            self.showToast(message: "No Internet Connection!")
            MAIN_DISPATCH.asyncAfter(deadline: .now() + 0.05) {
                self.tvFriendRequests.stopSkeletonAnimation()
            }
            return
        }
        let param = ["page" : currentPage]
        isLoading = true
        apiCalled = true
        NetworkManager.sharedInstance.getRequests(param: param) { (response) in
            self.isLoading = false
            self.tvFriendRequests.tableFooterView = nil
            MAIN_DISPATCH.async {
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
                        let requestsJson = dataObj["friendRequests"]
                        let requests = requestsJson.arrayValue.map({UserModel(json: $0["from"])})
                        self.allRequests.append(contentsOf: requests)
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
        MAIN_DISPATCH.async {
            self.showSpinner(
                onView          : self.tvFriendRequests,
                backgroundColor : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
            )
        }
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
        MAIN_DISPATCH.async {
            self.showSpinner(
                onView          : self.tvFriendRequests,
                backgroundColor : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
            )
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
extension FriendRequestVC : UITableViewDelegate, SkeletonTableViewDataSource {
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
        if apiCalled {
            if allRequests.count == 0 {
                tableView.setEmptyMessage("No Friend Requests")
            } else {
                tableView.restoreEmptyMessage()
            }
        } else {
            tableView.restoreEmptyMessage()
        }
        return allRequests.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let friendCell = tableView.dequeueReusableCell(withIdentifier: Constants.TVCELLS.FRIEND) as! FriendCell
        let row = indexPath.row
        friendCell.setupCellForRequests(allRequests[row])
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
        return friendCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.height / 8
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if currentPage < totalPages {
            if position > (tvFriendRequests.contentSize.height - 10 - scrollView.frame.size.height) {
                if isLoading {
                    // we are already fetching data
                    return
                }
                currentPage += 1
                tvFriendRequests.tableFooterView = Helper.showLoadingFooter(tvFriendRequests, .black)
                getAllRequests()
            }
        }
    }
}
