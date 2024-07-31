//
//  OtherProfileVC.swift
//  Quokka
//
//  Created by Muhammad Zubair on 16/12/2020.
//  Copyright © 2020 Codes Binary. All rights reserved.
//

import UIKit
import SwiftyJSON
import DTOverlayController
import LinearProgressView

class OtherProfileVC: UIViewController {
    /* MARK:- Outlets */
    /// Views
    @IBOutlet weak var viewMain        : UIView!
    @IBOutlet weak var viewCalling     : UIView!
    @IBOutlet weak var viewFriend1     : UIView!
    @IBOutlet weak var viewFriend2     : UIView!
    /// Labels
    @IBOutlet weak var lblName         : UILabel!
    @IBOutlet weak var lblQuestion1    : UILabel!
    @IBOutlet weak var lblQuestion2    : UILabel!
    @IBOutlet weak var lblQuestion3    : UILabel!
    @IBOutlet weak var lblCallTime     : UILabel!
    @IBOutlet weak var lblUserName     : UILabel!
    @IBOutlet weak var lblTotalFriends : UILabel!
    @IBOutlet weak var lblmyName       : UILabel!
    @IBOutlet weak var lblOtherName    : UILabel!
    /// TextViews
    @IBOutlet weak var txtViewAnswer1  : UITextView!
    @IBOutlet weak var txtViewAnswer2  : UITextView!
    @IBOutlet weak var txtViewAnswer3  : UITextView!
    /// ImageViews
    @IBOutlet weak var imgUserAvatar     : UIImageView!
    @IBOutlet weak var imgCallMyImage    : UIImageView!
    @IBOutlet weak var imgCallOtherImage : UIImageView!
    @IBOutlet weak var imgFriend1        : UIImageView!
    @IBOutlet weak var imgFriend2        : UIImageView!
    /// Buttons
    @IBOutlet weak var btnMenu           : UIButton!
    @IBOutlet weak var btnSeeAllReviews  : UIButton!
    @IBOutlet weak var btnShowMenu       : UIButton!
    /// Constraints
    @IBOutlet weak var constTopMainView  : NSLayoutConstraint!
    /// TableViews
    @IBOutlet weak var tvReviews      : UITableView!
    /// Outet Collections
    @IBOutlet var viewsRoundx2        : [UIView]!
    @IBOutlet var viewsRoundx6        : [UIView]!
    
    @IBOutlet weak var progressViewCall: LinearProgressView!
    /* MARK:- Properties */
    var otherUserObj  : UserModel?
    var isCalling     : Bool = false
    var apiCalled     : Bool = false
    var userID        : String?
    var preUserStatus : String = ""
    var userStatus    : String = ""
    var myImage    = ""
    var otherImage = ""
    var myName     = ""
    var otherName  = ""
    var callTimer            : Timer!
    var currentCallTime      : Int!
    var totalCallTime        : Int!
    /* MARK:- CLOSURES */
    var didLoadData       : (() -> Void)?
    /* MARK:- LifeCycle */
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
extension OtherProfileVC {
    func setupVC(){
        self.view.minFontSize()
        layoutVC()
        registerNibs()
        Helper.adjustTextViewHeight(arg: txtViewAnswer1)
        Helper.adjustTextViewHeight(arg: txtViewAnswer2)
        Helper.adjustTextViewHeight(arg: txtViewAnswer3)
        getUserDetails()
    }
    func layoutVC(){
        MAIN_DISPATCH.async { [self] in
            /// Setting Timer Label Stroke and Shadow
            lblCallTime.strokeText(strokeColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5), strokeWidth: -3.0)
            lblCallTime.layer.shadowColor   = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4)
            lblCallTime.layer.shadowRadius  = 3.0
            lblCallTime.layer.shadowOpacity = 1.0
            lblCallTime.layer.shadowOffset  = CGSize(width: 0, height: 4)
            lblCallTime.layer.masksToBounds = false
            if isCalling {
                viewCalling.alpha = 1.0
                constTopMainView.constant = viewCalling.bounds.height
            } else {
                viewCalling.alpha = 0.0
                constTopMainView.constant = 0
            }
            for v in viewsRoundx6 {
                v.layer.cornerRadius = v.bounds.height / 6
            }
            for v in viewsRoundx2 {
                v.layer.cornerRadius = v.bounds.height / 2
            }
            viewMain.layer.cornerRadius = 30
            viewMain.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        }
        showCallingView()
    }
    func showCallingView(){
        if isCalling{
            lblmyName.text = myName
            lblOtherName.text = otherName
            if myImage == "" {
                imgCallMyImage.image = UIImage(named: "Quokka-Placeholder")
            } else {
                Helper.setImage(imageView: imgCallMyImage, imageUrl: myImage, placeholder: "Quokka-Placeholder")
            }
            if otherImage == ""{
                imgCallOtherImage.image = UIImage(named: "Quokka-Placeholder")
            }
            else{
                Helper.setImage(imageView: imgCallOtherImage, imageUrl: otherImage, placeholder: "Quokka-Placeholder")
            }
            startCallTimer()
        }
    }
    func startCallTimer(){
        callTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCallTime), userInfo: nil, repeats: true)
    }
    @objc func updateCallTime(){
        showCallTime(seconds: currentCallTime)
        if currentCallTime != 0 {
            currentCallTime -= 1
            progressViewCall.setProgress((Float(currentCallTime)/Float(totalCallTime)) * 100.0, animated: true)
        }
        else{
            callTimer.invalidate()
            viewCalling.alpha = 0.0
            self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
        }
    }
    func registerNibs(){
        let reviewNib = UINib(nibName: Constants.TVCELLS.REVIEW,bundle: nil)
        tvReviews.register(
            reviewNib,
            forCellReuseIdentifier: Constants.TVCELLS.REVIEW
        )
    }
    func loadData(){
        if let userObj = otherUserObj {
            btnMenu.isUserInteractionEnabled = true
            btnMenu.alpha = 1.0
            if userObj.avatarUrl == "" {
                imgUserAvatar.image = UIImage(named: "Quokka-Placeholder")
            } else {
                Helper.setImage(imageView: imgUserAvatar, imageUrl: userObj.avatarUrl, placeholder: "Quokka-Placeholder")
            }
            lblName    .text = userObj.displayName
            lblUserName.text = "@\(userObj.userName)"
            if userObj.reviews.count == 0 {
                btnSeeAllReviews.alpha = 0.0
            }
            setQuestion()
            if userObj.profileAnswers[0] == "" {
                txtViewAnswer1.text = QUESTION_SUGGESTIONS[0]
            } else {
                txtViewAnswer1.text = userObj.profileAnswers[0]
            }
            if userObj.profileAnswers[1] == "" {
                txtViewAnswer2.text = QUESTION_SUGGESTIONS[1]
            } else {
                txtViewAnswer2.text = userObj.profileAnswers[1]
            }
            if userObj.profileAnswers[2] == "" {
                txtViewAnswer3.text = QUESTION_SUGGESTIONS[2]
            } else {
                txtViewAnswer3.text = userObj.profileAnswers[2]
            }
            Helper.adjustTextViewHeight(arg: txtViewAnswer1)
            Helper.adjustTextViewHeight(arg: txtViewAnswer2)
            Helper.adjustTextViewHeight(arg: txtViewAnswer3)
            viewMain.setNeedsLayout()
            viewMain.layoutIfNeeded()
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
    func setQuestion() {
        lblQuestion1.text = QUESTIONS[0]
        lblQuestion2.text = QUESTIONS[1]
        lblQuestion3.text = QUESTIONS[2]
    }
    /// Call
    func showCallTime (seconds : Int) {
        let secs = (seconds % 3600) % 60
        let mins = (seconds % 3600) / 60
        var stringSec = "\(secs)"
        if stringSec.count ==  1 {
            stringSec = "0\(stringSec)"
        }
        var stringMins = "\(mins)"
        if stringMins.count ==  1 {
            stringMins = "0\(stringMins)"
        }
        self.lblCallTime.text = "\(stringMins):\(stringSec)"
    }
}
/* MARK:- Actions */
extension OtherProfileVC {
    @IBAction func showMenu(_ sender : UIButton){
        let addRemoveVC = AddRemoveFriendVC(
            nibName : Constants.VCNibs.ADD_REMOVE,
            bundle  : nil)
        addRemoveVC.userObj    = otherUserObj
        addRemoveVC.userStatus = userStatus
        addRemoveVC.didLoadData = { [weak self] () in
            self!.getUserDetails(false)
        }
        let overlayController = DTOverlayController(viewController: addRemoveVC)
        overlayController.overlayViewCornerRadius = 30
        overlayController.overlayHeight = .dynamic(0.4)
        present(overlayController, animated: true, completion: nil)
    }
    @IBAction func tapAllReviews(_ sender : UIButton){
        let reviewsVC = ReviewsVC(
            nibName : Constants.VCNibs.REVIEWS,
            bundle  : nil)
        reviewsVC.otherUserId = otherUserObj!.id
        let overlayController = DTOverlayController(viewController: reviewsVC)
        overlayController.overlayViewCornerRadius = 30
        overlayController.overlayHeight = .dynamic(0.95)
        present(overlayController, animated: true, completion: nil)
    }
    @IBAction func endCallTapped(_ sender: UIButton){
        callTimer.invalidate()
        print("end tapped")
        NotificationCenter.default.post(name: .endCall, object: nil)
        self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
    }
}
/* MARK:- Api Methods */
extension OtherProfileVC {
    func getUserDetails(_ isShowLoader : Bool = true){
        if isShowLoader {
            MAIN_DISPATCH.async {
                Helper.showViewSkeletonView(view: self.viewMain)
            }
        }
        if !Reachability.isConnectedToNetwork() {
            self.showToast(message: "No Internet Connection!")
            MAIN_DISPATCH.async {
                self.viewMain.stopSkeletonAnimation()
            }
            return
        }
        guard let id = userID else {
            self.showToast(message: "Invalid User ID")
            MAIN_DISPATCH.async {
                self.viewMain.stopSkeletonAnimation()
            }
            return
        }
        let param = ["id" : id]
        apiCalled = true
        NetworkManager.sharedInstance.getOtherUserProfile(param: param) { (response) in
            switch response.result {
            case .success(_):
                do {
                    let apiData = try JSON(data: response.data!)
                    Helper.debugLogs(any: apiData)
                    let dataObj = apiData["data"]
                    let message = dataObj["message"].stringValue
                    if response.response?.statusCode == 200 {
                        MAIN_DISPATCH.async {
                            self.viewMain.hideSkeleton()
                        }
                        let userObj     = dataObj["user"]
                        self.userStatus = dataObj["status"].stringValue
                        self.otherUserObj = UserModel(json: userObj)
                        self.tvReviews.reloadData()
                        self.loadData()
                    } else if response.response?.statusCode == 401 {
                        self.showToast(message: "UnAuthorized : User Not Found")
                        self.logoutUser()
                    } else if response.response?.statusCode == 400 {
                        self.showAlertWithAction(title: "Profile Unavaible", message: "Actions are not allowed for this page") { (completed) in
                            if completed {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
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
/* MARK:- TableView Delegate & DataSource */
extension OtherProfileVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if apiCalled {
            if otherUserObj?.reviews.count == 0 {
                tableView.setEmptyMessage("No Reviews Yet")
            } else {
                tableView.restoreEmptyMessage()
            }
        } else {
            tableView.restoreEmptyMessage()
        }
        return otherUserObj?.reviews.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reviewCell = tableView.dequeueReusableCell(withIdentifier: Constants.TVCELLS.REVIEW) as! ReviewCell
        let row = indexPath.row
        reviewCell.setReviewCell(review: otherUserObj!.reviews[row])
        return reviewCell
    }
}
