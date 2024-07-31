//
//  SettingsVC.swift
//  Quokka
//
//  Created by Muhammad Zubair on 30/01/2021.
//  Copyright © 2021 Codes Binary. All rights reserved.
//

import UIKit
import MessageUI
import SkeletonView
import SwiftyJSON
import SCSDKLoginKit

class SettingsVC: UIViewController, MFMailComposeViewControllerDelegate {
    
    /* MARK: OUTLETS */
    /// Views
    @IBOutlet weak var viewMain     : UIView!
    @IBOutlet weak var viewImgUser  : UIView!
    @IBOutlet weak var viewFriend1  : UIView!
    @IBOutlet weak var viewFriend2  : UIView!
    /// ImageViews
    @IBOutlet weak var imgUserAvatar : UIImageView!
    @IBOutlet weak var imgFriend1    : UIImageView!
    @IBOutlet weak var imgFriend2    : UIImageView!
    /// Buttons
    @IBOutlet weak var btnSync         : UIButton!
    /// Labels
    @IBOutlet weak var lblName         : UILabel!
    @IBOutlet weak var lblUsername     : UILabel!
    @IBOutlet weak var lblTotalFriends : UILabel!
    @IBOutlet weak var lblAppVersion   : UILabel!
    /// Outet Collections
    @IBOutlet var viewsRound           : [UIView]!
    @IBOutlet var viewsRoundx8         : [UIView]!
    
    /* MARK:- Properties */
    
    /* MARK:- LifeCycle */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutVC()
    }
}

/* MARK:- Methods */
extension SettingsVC {
    func setupVC(){
        self.view.minFontSize()
        loadData()
        getUserDetails()
    }
    func layoutVC(){
        MAIN_DISPATCH.asyncAfter(deadline: .now() + 0.05) { [self] in
            for v in viewsRound {
                v.layer.cornerRadius = v.bounds.height / 2
            }
            for v in viewsRoundx8 {
                v.layer.cornerRadius = v.bounds.height / 8
            }
        }
    }
    func loadData(){
        layoutVC()
        if let userObj = Constants.sharedInstance.USER {
            lblAppVersion.text = "Quokka V\( Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)"
            if !PROFILE_COLORS_DICT.keys.contains(userObj.color) || userObj.color == "" {
                viewImgUser.borderColor = PROFILE_COLORS_DICT[Constants.sharedInstance.selectedColor]
            } else {
                viewImgUser.borderColor = PROFILE_COLORS_DICT[userObj.color]
            }
            if userObj.avatarUrl == "" {
                imgUserAvatar.image = UIImage(named: "Quokka-Placeholder")
            } else {
                Helper.setImage(imageView: imgUserAvatar, imageUrl: userObj.avatarUrl, placeholder: "Quokka-Placeholder")
            }
            lblName    .text = userObj.displayName
            lblUsername.text = "@\(userObj.userName)"
            if userObj.friends.count == 0 {
                self.viewFriend1.alpha = 1.0
                self.viewFriend2.alpha = 1.0
                self.imgFriend1.image = nil
                self.imgFriend2.image = nil
                self.lblTotalFriends.text = "\(userObj.friends.count) friends"
            } else if userObj.friends.count == 1 {
                self.viewFriend1.alpha = 0.0
                self.viewFriend2.alpha = 1.0
                if userObj.friends[0].avatarUrl == "" {
                    imgFriend2.image = UIImage(named: "Quokka-Placeholder")
                } else {
                    Helper.setImage(imageView: imgFriend2, imageUrl: userObj.friends[0].avatarUrl, placeholder: "Quokka-Placeholder")
                }
                self.lblTotalFriends.text = "\(userObj.friends.count) friend"
            } else {
                self.viewFriend1.alpha = 1.0
                self.viewFriend2.alpha = 1.0
                if userObj.friends[0].avatarUrl == "" {
                    imgFriend1.image = UIImage(named: "Quokka-Placeholder")
                } else {
                    Helper.setImage(imageView: imgFriend1, imageUrl: userObj.friends[1].avatarUrl, placeholder: "Quokka-Placeholder")
                }
                if userObj.friends[1].avatarUrl == "" {
                    imgFriend2.image = UIImage(named: "Quokka-Placeholder")
                } else {
                    Helper.setImage(imageView: imgFriend2, imageUrl: userObj.friends[1].avatarUrl, placeholder: "Quokka-Placeholder")
                }
                self.lblTotalFriends.text = "\(userObj.friends.count) friends"
            }
        } else {
            let topMostViewController = UIApplication.shared.topMostViewController()
            topMostViewController?.logoutUser()
        }
    }
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["michael@hiquokka.com"])
            present(mail, animated: true)
        } else {
            self.showToast(message: "Please install native mail app first!")
        }
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    func fetchUserInfo() {
        if !Reachability.isConnectedToNetwork() {
            self.showToast(message: "No Internet Connection!")
            return
        }
        MAIN_DISPATCH.async {
            self.showSpinner(onView: self.btnSync,indicatorColor: .black)
        }
        let graphQLQuery = "{me{externalId, displayName, bitmoji{avatar}}}"
        let variables = ["page": "bitmoji"]
        SCSDKLoginClient.fetchUserData(withQuery: graphQLQuery, variables: variables, success: { (resources: [AnyHashable: Any]?) in
            guard let resources = resources,
                  let data = resources["data"] as? [String: Any],
                  let me = data["me"] as? [String: Any] else { return }
            var avatarURL = ""
            if let bitmoji = me["bitmoji"] as? [String : Any] {
                if let avatarUrl = bitmoji["avatar"] as? String {
                    avatarURL = avatarUrl
                }
            }
            if let user = Constants.sharedInstance.USER {
                if user.avatarUrl == avatarURL {
                    MAIN_DISPATCH.async {
                        self.removeSpinner()
                    }
                } else {
                    self.updateAvatar(url: avatarURL)
                }
            }
        }, failure: { (error: Error?, isUserLoggedOut: Bool) in
            MAIN_DISPATCH.async {
                self.removeSpinner()
            }
        })
    }
}
/* MARK:- Actions */
extension SettingsVC {
    @IBAction func logoutTapped(_ sender: UIButton){
        if Constants.sharedInstance.isSearching || Constants.sharedInstance.isResponsing || Constants.sharedInstance.isWaiting || Constants.sharedInstance.isAnimating || Constants.sharedInstance.isUserInCall{
            showAlert(message: "You cannot logout at this time. Please cancel the call first.")
        }
        else{
            self.logoutUser()
        }
    }
    @IBAction func getInTouchTapped(_ sender: UIButton){
        sendEmail()
    }
    @IBAction func privacyTapped(_ sender: UIButton){
        if let url = URL(string: "https://www.hiquokka.com/privacy/"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    @IBAction func termsTapped(_ sender: UIButton){
        if let url = URL(string: "https://www.hiquokka.com/privacy/"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    @IBAction func syncTapped(_ sender: UIButton){
        fetchUserInfo()
    }
    
}
/* MARK:- Api Methods */
extension SettingsVC {
    func getUserDetails(){
        MAIN_DISPATCH.async {
            Helper.showViewSkeletonView(view: self.viewMain)
        }
        if !Reachability.isConnectedToNetwork() {
            self.showToast(message: "No Internet Connection!")
            MAIN_DISPATCH.async {
                self.viewMain.stopSkeletonAnimation()
            }
            return
        }
        NetworkManager.sharedInstance.getMyProfile() { (response) in
            MAIN_DISPATCH.async {
                self.viewMain.hideSkeleton()
            }
            switch response.result {
            case .success(_):
                do {
                    let apiData = try JSON(data: response.data!)
                    Helper.debugLogs(any: apiData)
                    let dataObj = apiData["data"]
                    let message = dataObj["message"].stringValue
                    if response.response?.statusCode == 200 {
                        let userObj = dataObj["user"]
                        Constants.sharedInstance.USER = UserModel(json: userObj)
                        Constants.sharedInstance.TOTAL_CALLS = dataObj["calls"].intValue
                        Constants.sharedInstance.TODAY_CALLS = dataObj["callsToday"].intValue
                        Constants.sharedInstance.LAST_CALL = dataObj["time"].stringValue
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
    
    func updateAvatar(url : String){
        let param = ["avatar" : url]
        if !Reachability.isConnectedToNetwork() {
            self.showToast(message: "No Internet Connection!")
            self.removeSpinner()
            return
        }
        NetworkManager.sharedInstance.updateAvatar(param: param) { (response) in
            self.removeSpinner()
            switch response.result {
            case .success(_):
                do {
                    let apiData = try JSON(data: response.data!)
                    Helper.debugLogs(any: apiData)
                    let dataObj = apiData["data"]
                    let message = dataObj["message"].stringValue
                    if response.response?.statusCode == 200 {
                        let userObj = dataObj["user"]
                        Constants.sharedInstance.USER = UserModel(json: userObj)
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
