//
//  ProfileVC.swift
//  Quokka
//
//  Created by Muhammad Zubair on 26/11/2020.
//  Copyright © 2020 Codes Binary. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher
import XLPagerTabStrip
import DTOverlayController
import LinearProgressView

class ProfileVC: ButtonBarPagerTabStripViewController {
    
    /* MARK: OUTLETS */
    /// Views
    @IBOutlet weak var viewMain          : UIView!
    @IBOutlet weak var viewCalling       : UIView!
    @IBOutlet weak var viewProfileImage  : UIView!
    @IBOutlet weak var viewResponse      : UIView!
    @IBOutlet weak var viewCallTop       : UIView!
    /// ImageViews
    @IBOutlet weak var imgUserAvatar     : UIImageView!
    @IBOutlet weak var imgCallMyImage    : UIImageView!
    @IBOutlet weak var imgCallOtherImage : UIImageView!
    /// Buttons
    @IBOutlet weak var btnColor          : UIButton!
    @IBOutlet weak var btnCancel         : UIButton!
    @IBOutlet weak var btnSaveResponse   : UIButton!
    /// Labels
    @IBOutlet weak var lblName           : UILabel!
    @IBOutlet weak var lblUsername       : UILabel!
    @IBOutlet weak var lblCallTime       : UILabel!
    @IBOutlet weak var lblmyName         : UILabel!
    @IBOutlet weak var lblOtherName      : UILabel!
    /// CollectionViews
    @IBOutlet weak var cvQuestions       : UICollectionView!
    /// Constraints
    @IBOutlet weak var constTopMainView         : NSLayoutConstraint!
    @IBOutlet weak var constBottomResponseView  : NSLayoutConstraint!
    /// Outet Collections
    @IBOutlet var viewsRound             : [UIView]!
    /// Outlet ProgressView
    @IBOutlet weak var progressViewCall: LinearProgressView!
    
    /* MARK:- Properties */
    var isCalling : Bool = false
    let dataController = ProfileQuestionDataController()
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutVC()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isCalling = false
        didLoadData?()
    }
    /// Pager ViewControllers
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let recentConvoVC = RecentConvoVC(
            nibName : Constants.VCNibs.RECENT_CONVO,
            bundle  : nil)
        let friendsVC = FriendsVC(
            nibName : Constants.VCNibs.FRIENDS,
            bundle  : nil)
        friendsVC.profileReference = self
        let trophiesVC = TrophiesVC(
            nibName : Constants.VCNibs.TROPHIES,
            bundle  : nil)
        trophiesVC.profileReference = self
        let reviewsVC = ReviewsVC(
            nibName : Constants.VCNibs.REVIEWS,
            bundle  : nil)
        return [recentConvoVC, friendsVC, trophiesVC, reviewsVC]
    }
}

/* MARK:- Methods */
extension ProfileVC {
    func setupVC(){
        self.view.minFontSize()
        registerNibs()
        setupButtonBar()
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
            for v in viewsRound {
                v.layer.cornerRadius = v.bounds.height / 2
            }
            viewMain.layer.cornerRadius = 30
            viewMain.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        }
    }
    func loadData(){
        if let userObj = Constants.sharedInstance.USER {
            if !PROFILE_COLORS_DICT.keys.contains(userObj.color) || userObj.color == "" {
                viewProfileImage.backgroundColor = PROFILE_COLORS_DICT[Constants.sharedInstance.selectedColor]
                btnColor.backgroundColor = PROFILE_COLORS_DICT[Constants.sharedInstance.selectedColor]
            } else {
                viewProfileImage.backgroundColor = PROFILE_COLORS_DICT[userObj.color]
                btnColor        .backgroundColor = PROFILE_COLORS_DICT[userObj.color]
            }
            if userObj.avatarUrl == "" {
                imgUserAvatar.image = UIImage(named: "Quokka-Placeholder")
            } else {
                Helper.setImage(imageView: imgUserAvatar, imageUrl: userObj.avatarUrl, placeholder: "Quokka-Placeholder")
            }
            lblName    .text = userObj.displayName
            lblUsername.text = "@\(userObj.userName)"
        } else {
            let topMostViewController = UIApplication.shared.topMostViewController()
            topMostViewController?.logoutUser()
        }
        showCallingView()
    }
    func setupButtonBar(){
        // change selected bar color
        settings.style.buttonBarBackgroundColor     = .clear
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor   = .clear
        settings.style.buttonBarItemFont = UIFont(name: "Apercu Pro Bold", size: 18.0) ?? .systemFont(ofSize: 18.0)
        settings.style.selectedBarHeight = 0.5
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailableWidth = false
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .gray
            newCell?.label.textColor = .black
        }
    }
    func registerNibs(){
        let questionNib = UINib(nibName: Constants.CVCELLS.PROFILE_QUESTION,bundle: nil)
        cvQuestions.register(
            questionNib,
            forCellWithReuseIdentifier: Constants.CVCELLS.PROFILE_QUESTION)
        cvQuestions.dataSource = self.dataController
        cvQuestions.delegate   = self.dataController
        
    }
    func setupResponseView(){
        constBottomResponseView.constant = KEYBOARD_HEIGHT - 10
        self.view.layoutIfNeeded()
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
extension ProfileVC {
    @IBAction func colorTapped(_ sender: UIButton){
        let colorVC = ColorVC(nibName: Constants.VCNibs.COLOR, bundle: nil)
        colorVC.userAvatar  = imgUserAvatar.image ?? UIImage()
        colorVC.didLoadData = { [weak self] (selectedColor) in
            self!.updateColor(color: selectedColor)
        }
        let overlayController = DTOverlayController(viewController: colorVC)
        overlayController.overlayViewCornerRadius = 30
        overlayController.overlayHeight = .dynamic(0.3)
        present(overlayController, animated: true, completion: nil)
    }
    @IBAction func settingsTapped(_ sender: UIButton){
        let settingsVC = SettingsVC(
            nibName : Constants.VCNibs.SETTINGS,
            bundle  : nil)
        let overlayController = DTOverlayController(viewController: settingsVC)
        overlayController.overlayViewCornerRadius = 30
        overlayController.overlayHeight = .dynamic(0.9)
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
extension ProfileVC {
    func updateColor(color : String){
        let param = ["color" : color]
        if !Reachability.isConnectedToNetwork() {
            self.showToast(message: "No Internet Connection!")
            return
        }
        self.showSpinner(onView: self.view, title: "Updating", backgroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5))
        NetworkManager.sharedInstance.updateColor(param: param) { (response) in
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

