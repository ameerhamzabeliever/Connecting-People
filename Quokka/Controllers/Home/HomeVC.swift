//
//  HomeVC.swift
//  Quokka
//
//  Created by Muhammad Zubair on 23/11/2020.
//  Copyright © 2020 Codes Binary. All rights reserved.
//

import UIKit
import SwiftyJSON
import LinearProgressView
import DTOverlayController
import SocketIO
import AgoraRtcKit

class HomeVC: UIViewController {
    
    /* MARK:- Outlets */
    /// Constraints
    @IBOutlet weak var consViewSearchVertical    : NSLayoutConstraint!
    @IBOutlet weak var consViewSearchingVertical : NSLayoutConstraint!
    @IBOutlet weak var consViewOtherUserVertical : NSLayoutConstraint!
    /// Views
    @IBOutlet weak var viewUserOutter         : UIView!
    @IBOutlet weak var viewUserInnerTop       : UIView!
    @IBOutlet weak var viewUserInnerBottom    : UIView!
    @IBOutlet weak var viewMyEmoji            : UIView!
    @IBOutlet weak var viewOtherName          : UIView!
    @IBOutlet weak var viewEmoji              : UIView!
    @IBOutlet weak var viewInviteFriend       : UIView!
    @IBOutlet weak var viewMoreEmoji          : UIView!
    @IBOutlet weak var viewCallTop            : UIView!
    @IBOutlet weak var viewNotAvailable       : UIView!
    @IBOutlet weak var viewSearch             : UIView!
    @IBOutlet weak var viewSearching          : UIView!
    @IBOutlet weak var viewCallingAnimate     : UIView!
    @IBOutlet weak var viewSearched           : UIView!
    @IBOutlet weak var viewWaitTimer          : UIView!
    @IBOutlet weak var viewSuggestion         : UIView!
    @IBOutlet weak var viewBtnSuggestion      : UIView!
    @IBOutlet weak var viewResponseTime       : UIView!
    /// ProgressViews
    @IBOutlet weak var progressViewCall       : LinearProgressView!
    @IBOutlet weak var progressViewWait       : LinearProgressView!
    /// ImageViews
    @IBOutlet weak var imgUserAvatar          : UIImageView!
    @IBOutlet weak var imgMyEmoji             : UIImageView!
    @IBOutlet weak var imgCallingAnimate      : UIImageView!
    @IBOutlet weak var imgOthersDP            : UIImageView!
    @IBOutlet weak var imgOtherEmoji          : UIImageView!
    /// Labels
    @IBOutlet weak var lblSearchTime          : UILabel!
    @IBOutlet weak var lblWaitTime            : UILabel!
    @IBOutlet weak var lblCallTime            : UILabel!
    @IBOutlet weak var lblAvailableTime       : UILabel!
    @IBOutlet weak var lblOthersName          : UILabel!
    @IBOutlet weak var lblPartyTime           : UILabel!
    @IBOutlet weak var lblResponseTime        : UILabel!
    /// Buttons
    @IBOutlet weak var btnMyEmoji             : UIButton!
    @IBOutlet weak var btnMic                 : UIButton!
    @IBOutlet weak var btnVolume              : UIButton!
    @IBOutlet weak var btnOtherProfileVC      : UIButton!
    @IBOutlet weak var btnStartCall           : UIButton!
    
    /// TextViews
    @IBOutlet weak var txtViewSuggestion      : UITextView!
    /// CollectionViews
    @IBOutlet weak var cvEmojiRecent          : UICollectionView!
    @IBOutlet weak var cvEmojiMore            : UICollectionView!
    /// Outet Collections
    @IBOutlet var viewsRound                  : [UIView]!
    @IBOutlet var viewEmojis                  : [UIView]!
    @IBOutlet var imgsEmojis                  : [UIImageView]!
    @IBOutlet weak var buttonStack            : UIStackView!
    
    /* MARK:- Properties */
    var recentEmojis         : [String] = []
    var totalCallTime        : Int      = 60
    var totalWaitTime        : Int      = 10
    var totalSearchTime      : Int      = 0
    var animationTime        : Int      = 5
    var totalResponseTime    : Int      = 0
    var currentCallTime      : Int!
    var currentWaitTime      : Int!
    var currentSearchTime    : Int!
    var currentAvailableTime : Int!
    var currentResponseTime  : Int!
    var callTimer            : Timer!
    var searchTimer          : Timer!
    var waitTimer            : Timer!
    var availableTimer       : Timer!
    var responseTimer        : Timer!
    /// Socket Client
    var socket      : SocketIOClient? = nil
    /// AgoraKit Engine
    var agoraKit    : AgoraRtcEngineKit?
    /// Timer - To make Animation in repititive State
    var animationTimer       : Timer?
    var isCalling            : Bool     = false
    var isSearched           : Bool     = false
    var isAuthorized         : Bool     = false
    var isConnecting         : Bool     = false
    var isResponse           : Bool     = false
    var beforeStartCall      : Bool     = true
    var isSpeakerTapped      : Bool     = true
    var isMicTapped          : Bool     = true
    var selectedEmojiName    : String   = ""
    var otherUser_id         : String   = ""
    var userStatus           : String   = ""
    var callId               : String   = ""
    var appInviteUrl         : String   = "https://hiquokka.page.link/app"
    /// Plus Degree Animation
    let degrees              : CGFloat = 10.0
    /// Minus Degree Animation
    let minusDegree          : CGFloat = -10.0
    /// authorizing user
    var auth_Message         : String  = ""
    ///Model
    var otherUserObj         : SearchingModel?
    var otherUser            : UserModel?
    /* MARK:- LifeCycle */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        settingVariables()
        loadData()
        getMyProfile()
        showCallTime(seconds: currentCallTime)
        showSearchTime()
        observerNotification()
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        if isAuthorized{
            isAuthorized = false
            manager.setConfigs([.reconnects(false)])
            socket?.disconnect()
            manager.removeSocket(socket!)
            socket = nil

        }
    }
}
/* MARK:- Methods */
extension HomeVC {
    func setupVC(){
        self.view.minFontSize()
        layoutVC()
        registerNibs()
        self.saveKeyboardHeightGlobaly()
    }
    func settingVariables(){
        currentCallTime   = totalCallTime
        currentWaitTime   = totalWaitTime
        currentSearchTime = totalSearchTime
        currentResponseTime = totalResponseTime
    }
    func layoutVC(){
        /// Setting Timer Label Stroke and Shadow
        lblCallTime.strokeText(strokeColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5), strokeWidth: -3.0)
        lblCallTime.layer.shadowColor   = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4)
        lblCallTime.layer.shadowRadius  = 3.0
        lblCallTime.layer.shadowOpacity = 1.0
        lblCallTime.layer.shadowOffset  = CGSize(width: 0, height: 4)
        lblCallTime.layer.masksToBounds = false
        MAIN_DISPATCH.async { [self] in
            for v in viewsRound {
                v.layer.cornerRadius = v.bounds.height / 2
            }
            viewUserOutter     .layer.cornerRadius = viewUserOutter.bounds.height / 4
            viewUserInnerBottom.layer.cornerRadius = viewUserOutter.bounds.height / 4
            viewUserInnerTop   .layer.cornerRadius = 30
            viewMyEmoji         .layer.cornerRadius = viewMyEmoji    .bounds.height / 4
            viewOtherName      .layer.cornerRadius = viewOtherName .bounds.height / 4
            viewMoreEmoji      .layer.cornerRadius = 30
            viewUserOutter     .layer.maskedCorners = [
                .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            viewUserInnerBottom.layer.maskedCorners = [
                .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            viewUserInnerTop   .layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            viewMoreEmoji      .layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            if SCREEN_HEIGHT < 737 {
                consViewSearchVertical   .constant = 35
                consViewSearchingVertical.constant = 35
                consViewOtherUserVertical.constant = 30
            }
        }
    }
    func loadData(){
        recentEmojis = Constants.sharedInstance.RECENT_EMOJIS
        
        if imgMyEmoji.image == nil {
            viewEmoji.alpha        = 1.0
            viewInviteFriend.alpha = 0.0
        } else {
            if Constants.sharedInstance.isUserInCall{
                viewEmoji.alpha        = 0.0
                viewInviteFriend.alpha = 0.0
            }
            else{
                viewEmoji.alpha        = 0.0
                viewInviteFriend.alpha = 1.0
            }
        }
        if let user = Constants.sharedInstance.USER {
            if !PROFILE_COLORS_DICT.keys.contains(user.color) || user.color == "" {
                viewUserInnerTop   .backgroundColor = PROFILE_COLORS_DICT[Constants.sharedInstance.selectedColor]
                viewUserInnerBottom.backgroundColor = PROFILE_COLORS_DICT[Constants.sharedInstance.selectedColor]
                viewUserOutter     .backgroundColor = PROFILE_COLORS_DICT[Constants.sharedInstance.selectedColor]!.lighter(by: 13)
            } else {
                viewUserInnerTop   .backgroundColor = PROFILE_COLORS_DICT[user.color]
                viewUserInnerBottom.backgroundColor = PROFILE_COLORS_DICT[user.color]
                viewUserOutter     .backgroundColor = PROFILE_COLORS_DICT[user.color]!.lighter(by: 13)
            }
            if user.avatarUrl == "" {
                imgUserAvatar.image = UIImage(named: "Quokka-Placeholder")
            } else {
                Helper.setImage(imageView: imgUserAvatar, imageUrl: user.avatarUrl, placeholder: "Quokka-Placeholder")
            }
            if user.emoji == "" {
                imgMyEmoji.image = nil
            } else {
                imgMyEmoji.image = UIImage(named: user.emoji)
                self.viewMyEmoji.alpha = 1.0
            }
        } else {
            self.logoutUser()
        }
    }
    func observerNotification(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(emitEndCall),
            name: NSNotification.Name("emitEndCall"),
            object: nil)
    }
    func checkCallValidations(){
        let restTime : CGFloat = Constants.sharedInstance.REST_DURATION
        if Constants.sharedInstance.TODAY_CALLS < Constants.sharedInstance.CALL_LIMIT {
            lblPartyTime.text        = "Party available in"
            let lastCallTimeString   = Constants.sharedInstance.LAST_CALL
            if lastCallTimeString != "" {
                let dateFormatter        = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                let lastCallTimeStamp    = dateFormatter.date(from: lastCallTimeString)
                let currentTime          = Date()
                let elapsedTime          = Helper.minutesBetweenDates( lastCallTimeStamp!,
                                                                       currentTime       )
                if elapsedTime > restTime {
                    showSearchView()
                } else {
                    let nextCallTimeStamp = Calendar.current.date(byAdding: .minute, value: Int(restTime), to: lastCallTimeStamp!)
                    let remainingMinutes = Helper.minutesBetweenDates( currentTime      ,
                                                                       nextCallTimeStamp!)
                    currentAvailableTime = Int(remainingMinutes * 60)
                    showAvailableView()
                }
            }
        } else {
            lblPartyTime.text        = "Daily Limit Reached"
            lblAvailableTime.text    = "Next Day"
            UIView.animate(withDuration: 0.5) {
                self.viewSearch      .alpha = 0.0
                self.viewNotAvailable.alpha = 1.0
            }
        }
    }
    func registerNibs(){
        let emojiNib = UINib(nibName: Constants.CVCELLS.EMOJI,bundle: nil)
        cvEmojiRecent.register(
            emojiNib,
            forCellWithReuseIdentifier: Constants.CVCELLS.EMOJI)
        cvEmojiMore.register(
            emojiNib,
            forCellWithReuseIdentifier: Constants.CVCELLS.EMOJI)
    }
    func backToHomeState(){
        UIView.animate(withDuration: 0.5) {
            self.viewCallTop       .alpha = 0.0
            self.viewSearch        .alpha = 1.0
            self.viewSearching     .alpha = 0.0
            self.viewSearched      .alpha = 0.0
            self.btnOtherProfileVC .alpha = 0.0
            self.viewEmoji         .alpha = 0.0
            self.viewInviteFriend  .alpha = 1.0
            self.viewWaitTimer     .alpha = 0.0
            self.viewCallingAnimate.alpha = 0.0
            self.viewResponseTime  .alpha = 0.0
            self.btnStartCall      .alpha = 0.0
        }
        if Constants.sharedInstance.isWaiting {
            endWaiting()
        }
        if Constants.sharedInstance.isSearching {
            endSearching()
        }
        if Constants.sharedInstance.isResponsing{
            endResponse()
        }
        if Constants.sharedInstance.isAnimating{
            endAnimation()
        }
    }
    func gotoFeedbackVC(){
        let feedbackVC = FeedbackVC(
            nibName: Constants.VCNibs.FEEDBACK,
            bundle : nil)
        feedbackVC.otherUser  = otherUser
        feedbackVC.userStatus = userStatus
        feedbackVC.callId     = callId
        navigationController?.pushViewController(feedbackVC, animated: true)
    }
    /// Emojis
    func showMoreEmojiView(){
        if viewMoreEmoji.alpha == 0.0 {
            UIView.animate(withDuration: 0.5) {
                self.viewMoreEmoji.alpha = 1.0
            }
            
        } else {
            UIView.animate(withDuration: 0.5) {
                self.viewMoreEmoji.alpha = 0.0
            }
        }
    }
    /// Searching
    func showSearchTime(){
        var stringSec = "\(currentSearchTime!)"
        if stringSec.count ==  1 {
            stringSec = "0\(stringSec)"
        }
        self.lblSearchTime.text = "\(stringSec) s"
    }
    func showResponseTime(){
        var stringSec = "\(currentResponseTime!)"
        if stringSec.count == 1{
            stringSec = "0\(stringSec)"
        }
        self.lblResponseTime.text = "\(stringSec) s"
    }
    func startSearching(){
        UIView.animate(withDuration: 0.5) {
            self.viewCallTop     .alpha = 1.0
            self.viewSearch      .alpha = 0.0
            self.viewSearching   .alpha = 1.0
            self.viewInviteFriend.alpha = 0.0
            self.viewEmoji       .alpha = 0.0
        }
        startSearchingTimer()
    }
    func startSearchingTimer(){
        Constants.sharedInstance.isSearching = true
        searchTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateSearchTime), userInfo: nil, repeats: true)
    }
    func startResponseTimer(){
        beforeStartCall = false
        UIView.animate(withDuration: 0.5) {
            self.btnStartCall      .alpha = 0.0
            self.viewResponseTime  .alpha = 1.0
            self.btnOtherProfileVC .alpha = 1.0
        }
        responseTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateResponseTime), userInfo: nil, repeats: true)
    }
    func getUser(){
        socket = manager.defaultSocket
        socket?.on(clientEvent: .connect){data,ack in
            print("socket connected")
            ///authenticate user
            self.socket!.emit("authenticate",
                              ["token": Constants.sharedInstance.httpHeaders["Authorization"]])
            self.socket?.on("authenticate") { dataArray, ack in
                let dataValue = JSON(dataArray)
                print(dataValue)
                self.auth_Message = dataValue[0]["msg"].stringValue
                if self.auth_Message == "Authorized User"{
                    self.isAuthorized = true
                    ///search other user
                    self.socket!.emit("searching")
                    self.socket?.on("searching"){ searchingData, ack in
                        let data = JSON(searchingData)
                        print(data)
                        self.otherUserObj = SearchingModel(json: data.arrayValue[0])
                        print(self.otherUserObj as Any)
                        if let user = self.otherUserObj {
                            if user._id != "" {
                            self.otherUser_id = user._id
                            if user.avatar == "" {
                                self.imgOthersDP.image = UIImage(named: "Quokka-Placeholder")
                            } else {
                                Helper.setImage(imageView: self.imgOthersDP, imageUrl: user.avatar, placeholder: "Quokka-Placeholder")
                            }
                            if user.emoji == ""{
                                self.imgOtherEmoji.image = UIImage(named: "e_11")
                            } else{
                                self.imgOtherEmoji.image = UIImage(named: user.emoji)
                            }
                            self.lblOthersName.text = user.name
                            if self.otherUser_id != "" {
                                self.getUserDetails()
                            }
                                self.isSearched = true
                            }
                        }
                    }
                    self.socket?.on("callConnect"){ responseData, ack in
                        let data = JSON(responseData)
                        print(data)
                        let message = dataValue[0]["msg"].stringValue
                        print(message)
                        if message != nil {
                            self.isResponse = true
                        }
                    }
                    self.socket?.on("endSearching"){endSearching, ack in
                        self.removeSpinner()
                        let data = JSON(endSearching)
                        print(data)
                        self.backToHomeState()
                    }
                    self.socket?.on("callCancel"){callEnd, ack in
                        self.removeSpinner()
                        let data = JSON(callEnd)
                        print(data)
                        let message = data[0]["msg"].stringValue
                        if message  == "call Cancel by other user"{
                            self.showAlertWithAction(message: "\(self.otherUserObj!.name) canceled the call") { (comp) in
                                if comp {
                                    self.backToHomeState()
                                }
                            }
                        }
                        self.backToHomeState()
                    }
                    self.socket?.on("callEnd"){callEnd, ack in
                        let data = JSON(callEnd)
                        print(data)
                        let message = data[0]["msg"].stringValue
                        self.callId = data[0]["callId"].stringValue
                        print(message)
                        if message  == "call Ended Successfuly"{
                            self.showAlertWithAction(message: "\(self.otherUserObj!.name) canceled the call") { (comp) in
                                if comp {
                                    self.endCall()
                                }
                            }
                        }
                        self.endCall()
                    }
                }
            }
        }
        socket?.connect()
    }
    func endSearching(){
        Constants.sharedInstance.isSearching = false
        currentSearchTime = totalSearchTime
        showSearchTime()
        searchTimer.invalidate()
    }
    func endResponse(){
        Constants.sharedInstance.isResponsing = false
        isResponse     = false
        currentResponseTime = totalResponseTime
        showResponseTime()
        if !beforeStartCall{
            beforeStartCall = true
            responseTimer.invalidate()
        }
    }
    /// emit endSearch
    func emitEndSearch(){
        if self.auth_Message == "Authorized User"{
            showSpinner(onView: self.view)
            self.socket?.emit("endSearching")
        }
        else{
            print("user unauthorized")
        }
    }
    /// Waiting
    func showWaitTime(){
        var stringSec = "\(currentWaitTime!)"
        if stringSec.count ==  1 {
            stringSec = "0\(stringSec)"
        }
        self.lblWaitTime.text = "Starting timer in \(stringSec)s"
    }
    func startWaiting(){
        UIView.animate(withDuration: 0.5) {
            self.viewCallingAnimate.alpha = 0.0
            self.viewSearched      .alpha = 1.0
            self.btnOtherProfileVC .alpha = 1.0
            self.viewWaitTimer     .alpha = 1.0
        }
        startWaitTimer()
    }
    func startWaitTimer(){
        Constants.sharedInstance.isWaiting = true
        waitTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateWaitTime), userInfo: nil, repeats: true)
    }
    func endWaiting(){
        Constants.sharedInstance.isWaiting       = false
        currentWaitTime = totalWaitTime
        waitTimer.invalidate()
        showWaitTime()
        progressViewWait.setProgress(100, animated: true)
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
    func startCalling(){
        UIView.animate(withDuration: 0.5) {
            self.viewWaitTimer .alpha = 0.0
            self.viewSuggestion.alpha = 1.0
        }
        endWaiting()
        startCallTimer()
    }
    func startCallTimer(){
        Constants.sharedInstance.isUserInCall = true
        callTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCallTime), userInfo: nil, repeats: true)
    }
    func endCall(){
        Constants.sharedInstance.isUserInCall   = false
        callTimer.invalidate()
        /// destroying channel
        agoraKit?.leaveChannel(nil)
        AgoraRtcEngineKit.destroy()
        currentSearchTime = totalCallTime
        showCallTime(seconds: currentCallTime)
        progressViewCall.setProgress(100, animated: false)
        UIView.animate(withDuration: 0.5) {
            self.viewCallTop      .alpha = 0.0
            self.viewSearch       .alpha = 1.0
            self.viewSearched     .alpha = 0.0
            self.btnOtherProfileVC.alpha = 0.0
            self.viewEmoji        .alpha = 0.0
            self.viewWaitTimer    .alpha = 0.0
            self.viewSuggestion   .alpha = 0.0
            self.buttonStack      .alpha = 0.0
        }
        gotoFeedbackVC()
    }
    /// emit endCall
    @objc func emitEndCall(){
        if self.auth_Message == "Authorized User"{
            showSpinner(onView: self.view)
            self.socket?.emit("callEnd",
                              ["userId": otherUserObj!._id])
            print("call End")
        }
        else{
            print("user unauthorized")
        }
    }
    /// emit cancelCall
    func emitCancelCall(){
        if self.auth_Message == "Authorized User"{
            showSpinner(onView: self.view)
            self.socket?.emit("callCancel",
                              ["userId": otherUserObj!._id])
        }
        else{
            print("user unauthorized")
        }
    }
    /// Suggestions
    func showSuggestions(){
        let index = Int.random(in: 0..<Constants.sharedInstance.SUGGESTIONS.count)
        self.txtViewSuggestion.text  = Constants.sharedInstance.SUGGESTIONS[index]
        /// Suggestion TextView Insets and Height Adjustment according to text
        self.txtViewSuggestion.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        self.suggestionTextViewHeight()
        UIView.animate(withDuration: 0.5) {
            self.viewBtnSuggestion.alpha = 0.0
            self.txtViewSuggestion.alpha = 1.0
        }
        MAIN_DISPATCH.asyncAfter(deadline: .now() + 4, execute: {
            UIView.animate(withDuration: 0.5) {
                self.viewBtnSuggestion.alpha = 1.0
                self.txtViewSuggestion.alpha = 0.0
            }
        })
    }
    func suggestionTextViewHeight() {
        txtViewSuggestion.translatesAutoresizingMaskIntoConstraints = true
        txtViewSuggestion.sizeToFit()
        txtViewSuggestion.isScrollEnabled = false
        if txtViewSuggestion.frame.height > 69 {
            MAIN_DISPATCH.async {
                self.txtViewSuggestion.layer.cornerRadius = 69/2
            }
        }
        let width  = txtViewSuggestion.bounds.width
        let height = txtViewSuggestion.bounds.height
        txtViewSuggestion.frame = CGRect(
            x: ((SCREEN_WIDTH * 0.768) - width)/2 ,
            y: (SCREEN_HEIGHT - height)/2 ,
            width : txtViewSuggestion.bounds.width,
            height: txtViewSuggestion.bounds.height)
        self.view.layoutIfNeeded()
    }
    /// Call Available
    func showAvailableTime (seconds : Int) {
        let secs  = (seconds % 3600) % 60
        let mins  = (seconds % 3600) / 60
        let hours = seconds / 3600
        var stringSec = "\(secs)"
        if stringSec.count ==  1 {
            stringSec = "0\(stringSec)"
        }
        var stringMins = "\(mins)"
        if stringMins.count ==  1 {
            stringMins = "0\(stringMins)"
        }
        var stringHours = "\(hours)"
        if stringHours.count ==  1 {
            stringHours = "0\(stringHours)"
        }
        if hours == 0 {
            if mins == 0 {
                self.lblAvailableTime.text = "\(stringSec)s"
            } else {
                self.lblAvailableTime.text = "\(stringMins)m \(stringSec)s"
            }
        } else {
            self.lblAvailableTime.text = "\(stringHours)h \(stringMins)m \(stringSec)s"
        }
        
    }
    func showSearchView(){
        UIView.animate(withDuration: 0.5) {
            self.viewNotAvailable.alpha = 0.0
            self.viewSearch.alpha = 1.0
        }
    }
    func showAvailableView(){
        UIView.animate(withDuration: 0.5) {
            self.viewSearch      .alpha = 0.0
            self.viewNotAvailable.alpha = 1.0
        }
        startAvailableTimer()
    }
    func startAvailableTimer(){
        availableTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateAvailableTime), userInfo: nil, repeats: true)
    }
    /// Animations
    func startAnimation(){
        UIView.animate(withDuration: 0.5) {
            self.viewResponseTime  .alpha  = 0.0
            self.viewSearching     .alpha = 0.0
            self.viewEmoji         .alpha = 0.0
            self.viewSearched      .alpha = 1.0
            self.btnOtherProfileVC .alpha = 0.0
            self.viewCallingAnimate.alpha = 1.0
        }
        startAnimationTimer()
    }
    func startAnimationTimer(){
        Constants.sharedInstance.isAnimating    = true
        animationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(animateCallingView), userInfo: nil, repeats: true)
    }
    func endAnimation(){
        animationTime = 5
        Constants.sharedInstance.isAnimating   = false
        animationTimer?.invalidate()
    }
    func shareAppURL(){
        // text to share
        ///TODO:- Change Text To Link
        let text = "Install Quokka\n\(appInviteUrl)"

        // set up activity view controller
        let textToShare            = [ text ]
        let activityViewController = UIActivityViewController(
            activityItems: textToShare,
            applicationActivities: nil
        )
        
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash

        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]

        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
}
/* MARK:- OBJ-C Methods */
extension HomeVC {
    @objc func updateSearchTime() {
        showSearchTime()
        let appstate = UIApplication.shared.applicationState
        if appstate == .background || appstate == .inactive {
            emitEndSearch()
        }
        if currentSearchTime < 30 {
            currentSearchTime += 1
            if currentSearchTime == 3 {
                if isAuthorized{
                    self.socket!.emit("searching")
                }
                else{
                    getUser()
                }
            }
            if isSearched{
                isSearched = false
                Constants.sharedInstance.isResponsing = true
                UIView.animate(withDuration: 0.5){ [self] in
                    self.viewSearching     .alpha = 0.0
                    self.viewSearched      .alpha = 1.0
                    self.btnStartCall      .alpha = 1.0
                    self.btnOtherProfileVC .alpha = 1.0
                }
                endSearching()
            }
        }
        else {
            endSearching()
            emitEndSearch()
        }
    }
    @objc func updateResponseTime(){
        showResponseTime()
        let appstate = UIApplication.shared.applicationState
        if appstate == .background || appstate == .inactive {
            viewResponseTime.alpha  = 0.0
            emitCancelCall()
        }
        if currentResponseTime < 12{
            currentResponseTime += 1
            if isResponse{
                endResponse()
                startAnimation()
            }
        }
        else{
            viewResponseTime.alpha  = 0.0
            endResponse()
            emitCancelCall()
        }
    }
    @objc func updateWaitTime() {
        showWaitTime()
        let appstate = UIApplication.shared.applicationState
        if appstate == .background || appstate == .inactive {
            emitCancelCall()
        }
        if currentWaitTime != 0 {
            currentWaitTime -= 1
            progressViewWait.setProgress((Float(currentWaitTime)/Float(totalWaitTime)) * 100.0, animated: true)
            if currentWaitTime <= 2{
                self.initializeAgoraEngine()
                self.joinChannel(token: "", channelId: otherUserObj!.channelName, uid: UInt(otherUserObj!.uid)!)
            }
            
        }
        else {
            if isConnecting{
                self.isConnecting = false
            }
            else {
                emitCancelCall()
            }
            endWaiting()
        }
    }
    @objc func updateCallTime() {
        showCallTime(seconds: currentCallTime)
        let appstate = UIApplication.shared.applicationState
        if appstate == .background || appstate == .inactive {
            emitEndCall()
        }
        if currentCallTime != 0 {
            currentCallTime -= 1
            progressViewCall.setProgress((Float(currentCallTime)/Float(totalCallTime)) * 100.0, animated: true)
        }
        else {
            callTimer.invalidate()
            emitEndCall()
        }
    }
    @objc func updateAvailableTime() {
        showAvailableTime(seconds: currentAvailableTime)
        if currentAvailableTime != 0 {
            currentAvailableTime -= 1
        }
        else {
            availableTimer.invalidate()
            showSearchView()
        }
    }
    @objc func animateCallingView(){
        let appstate = UIApplication.shared.applicationState
        if appstate == .background || appstate == .inactive {
            emitCancelCall()
        }
        if animationTime != 0 {
            animationTime -= 1
            let plusRadian : CGFloat = degrees * CGFloat((Double.pi/180))
            let minusRadian : CGFloat = minusDegree * CGFloat((Double.pi/180))
            /// First Animation To make View Goes clockwise
            UIView.animate(withDuration: 0.5, animations: {
                self.imgCallingAnimate.transform = CGAffineTransform(rotationAngle: plusRadian)
            }) { (success) in
                /// Second Animation to make view go antiClockWise
                UIView.animate(withDuration: 0.5, animations: {
                    self.imgCallingAnimate.transform = CGAffineTransform(rotationAngle: minusRadian)
                })
            }
        } else {
            Constants.sharedInstance.isAnimating = false
            endAnimation()
            startWaiting()
        }
    }
}
/* MARK:- Actions */
extension HomeVC {
    @IBAction func profileTapped(_ sender : UIButton) {
        let profileVC = ProfileVC(nibName: Constants.VCNibs.PROFILE, bundle: nil)
        profileVC.didLoadData = { [weak self] in
            if Constants.sharedInstance.isLogout {
                Constants.sharedInstance.isLogout = false
                self!.backToHome()
            } else {
                if !self!.isCalling && !Constants.sharedInstance.isWaiting && !Constants.sharedInstance.isSearching && !Constants.sharedInstance.isAnimating && !Constants.sharedInstance.isResponsing{
                    self!.getMyProfile()
                }
            }
        }
        if Constants.sharedInstance.isUserInCall{
            profileVC.isCalling  = true
            profileVC.myImage    = Constants.sharedInstance.USER?.avatarUrl ?? ""
            profileVC.myName     = Constants.sharedInstance.USER?.displayName ?? ""
            profileVC.otherImage = otherUserObj?.avatar ?? ""
            profileVC.otherName  = otherUserObj?.name ?? ""
            profileVC.currentCallTime = currentCallTime
            profileVC.totalCallTime   = totalCallTime
        }
        if availableTimer != nil {
            availableTimer.invalidate()
            currentAvailableTime = 0
        }
        Constants.sharedInstance.PROFILE_VC_REFERENCE = profileVC
        let overlayController = DTOverlayController(viewController: profileVC)
        overlayController.overlayViewCornerRadius = 30
        overlayController.overlayHeight = .dynamic(0.95)
        present(overlayController, animated: true, completion: nil)
    }
    @IBAction func myEmojiTapped(_ sender : UIButton) {
        if !Constants.sharedInstance.isUserInCall && !Constants.sharedInstance.isWaiting && !Constants.sharedInstance.isSearching {
            btnMyEmoji.isSelected = !btnMyEmoji.isSelected
            if btnMyEmoji.isSelected {
                UIView.animate(withDuration: 0.5) {
                    self.viewInviteFriend.alpha = 0.0
                    self.viewEmoji       .alpha = 1.0
                }
            } else {
                UIView.animate(withDuration: 0.5) {
                    self.viewInviteFriend.alpha = 1.0
                    self.viewEmoji       .alpha = 0.0
                }
            }
        }
    }
    @IBAction func emojiTapped(_ sender : UIButton) {
        for i in 0..<viewEmojis.count {
            viewEmojis[i].backgroundColor = .clear
            viewEmojis[i].transform = CGAffineTransform.identity
            imgsEmojis[i].transform = CGAffineTransform.identity
        }
        UIView.animate(withDuration: 0.5) {
            self.viewMoreEmoji   .alpha = 0.0
            self.viewEmoji       .alpha = 0.0
            self.viewMyEmoji     .alpha = 1.0
            self.viewInviteFriend.alpha = 1.0
        }
        let index                         = sender.tag
        selectedEmojiName                 = imgsEmojis[index].accessibilityLabel!
        btnMyEmoji.isSelected             = false
        viewEmojis[index].transform       = CGAffineTransform(scaleX: 1.5, y: 1.5)
        viewEmojis[index].backgroundColor = #colorLiteral(red: 0.768627451, green: 0.768627451, blue: 0.768627451, alpha: 0.4)
        updateEmoji()
    }
    @IBAction func moreEmojiTapped(_ sender : UIButton) {
        showMoreEmojiView()
    }
    @IBAction func searchTapped(_ sender: UIButton){
        if imgMyEmoji.image == nil {
            showToast(message: "Please,Choose Your Mood!")
            return
        }
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            startSearching()
        case AVAudioSession.RecordPermission.denied:
            showToast(message: "Please, Allow Microphone Access from Settings")
            return
        case AVAudioSession.RecordPermission.undetermined:
            print("Request permission here")
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
            })
        }
    }
    @IBAction func endTapped(_ sender: UIButton){
        if Constants.sharedInstance.isUserInCall {
            NotificationCenter.default.post(name: .endCall, object: nil)
        }else if Constants.sharedInstance.isSearching{
            emitEndSearch()
        }else if Constants.sharedInstance.isResponsing{
            emitCancelCall()
        }else if Constants.sharedInstance.isAnimating{
            emitCancelCall()
        }else if Constants.sharedInstance.isWaiting{
            emitCancelCall()
        }
        else{
            backToHomeState()
        }
    }
    @IBAction func flagTapped( _ sender: UIButton){
        let flagVC = FlagVC(nibName: Constants.VCNibs.FLAG, bundle: nil)
        let overlayController = DTOverlayController(viewController: flagVC)
        overlayController.overlayViewCornerRadius = 30
        overlayController.overlayHeight = .dynamic(0.35)
        present(overlayController, animated: true, completion: nil)
    }
    @IBAction func inviteTapped( _ sender: UIButton){
        shareAppURL()
    }
    @IBAction func suggestionTapped( _ sender: UIButton){
        showSuggestions()
    }
    @IBAction func otherProfileTapped( _ sender: UIButton){
        let otherProfileVC = OtherProfileVC(nibName: Constants.VCNibs.OTHER_PROFILE, bundle: nil)
        if Constants.sharedInstance.isUserInCall {
            otherProfileVC.isCalling  = true
            otherProfileVC.myImage    = Constants.sharedInstance.USER?.avatarUrl ?? ""
            otherProfileVC.myName     = Constants.sharedInstance.USER?.displayName ?? ""
            otherProfileVC.otherImage = otherUserObj?.avatar ?? ""
            otherProfileVC.otherName  = otherUserObj?.name ?? ""
            otherProfileVC.currentCallTime = currentCallTime
            otherProfileVC.totalCallTime   = totalCallTime
        }
        otherProfileVC.userID = otherUser_id
        let overlayController = DTOverlayController(viewController: otherProfileVC)
        overlayController.overlayViewCornerRadius = 30
        overlayController.overlayHeight = .dynamic(0.95)
        present(overlayController, animated: true, completion: nil)
    }
    @IBAction func didTapSpeaker(_ sender: UIButton){
        if isSpeakerTapped == true{
            btnVolume.setImage(UIImage(named: "volume_on"), for: .normal)
            agoraKit?.setEnableSpeakerphone(isSpeakerTapped)
            isSpeakerTapped = false
        }
        else if isSpeakerTapped == false{
            btnVolume.setImage(UIImage(named: "volume_mute"), for: .normal)
            agoraKit?.setEnableSpeakerphone(isSpeakerTapped)
            isSpeakerTapped = true
        }
    }
    @IBAction func didTapMic(_ sender: UIButton){
        if isMicTapped == true{
            btnMic.setImage(UIImage(named: "mic_mute"), for: .normal)
            agoraKit?.muteLocalAudioStream(isMicTapped)
            isMicTapped = false
        } 
        else if isMicTapped == false {
            btnMic.setImage(UIImage(named: "mic_on"), for: .normal)
            agoraKit?.muteLocalAudioStream(isMicTapped)
            isMicTapped = true
        }
    }
    @IBAction func didTapStart(_ sender : UIButton){
        self.socket!.emit("callConnect",
                          ["userId": otherUserObj!._id])
        startResponseTimer()
    }
}
/* MARK:- API Methods */
extension HomeVC {
    func getMyProfile(){
        if !Reachability.isConnectedToNetwork() {
            self.showToast(message: "No Internet Connection!")
            return
        }
        self.showSpinner(onView: self.view, indicatorColor: .black)
        NetworkManager.sharedInstance.getMyProfile(){ (response) in
            MAIN_DISPATCH.async {
                self.removeSpinner()
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
                        Constants.sharedInstance.LAST_CALL   = dataObj["time"].stringValue
                        self.loadData()
                        self.checkCallValidations()
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
                self.showToast(message: response.error?.localizedDescription ?? "Something went wrong")
            }
        }
    }
    func updateEmoji(){
        if !Reachability.isConnectedToNetwork() {
            self.showToast(message: "No Internet Connection!")
            return
        }
        self.showSpinner(onView: self.imgMyEmoji, indicatorColor: .black)
        let emojiParam = ["emoji" : selectedEmojiName]
        NetworkManager.sharedInstance.updateUserEmoji(param: emojiParam){ (response) in
            MAIN_DISPATCH.async {
                self.removeSpinner()
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
                self.showToast(message: response.error?.localizedDescription ?? "Something went wrong")
            }
        }
    }
    func getUserDetails(){
        let param = ["id" : otherUser_id]
        NetworkManager.sharedInstance.getOtherUserProfile(param: param) { (response) in
            switch response.result {
            case .success(_):
                do{
                    let apiData = try JSON(data: response.data!)
                    Helper.debugLogs(any: apiData)
                    let dataObj = apiData["data"]
                    let message = dataObj["message"].stringValue
                    if response.response?.statusCode == 200{
                        let userObj     = dataObj["user"]
                        self.userStatus = dataObj["status"].stringValue
                        self.otherUser = UserModel(json: userObj)
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
/* MARK:- CollectionView DataSource & Delegate */
extension HomeVC :
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView ==  cvEmojiMore {
            return 89
        } else {
            if Constants.sharedInstance.RECENT_EMOJIS.count > 8 {
                return 8
            } else {
                return Constants.sharedInstance.RECENT_EMOJIS.count
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let emojiCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CVCELLS.EMOJI, for: indexPath) as! EmojiCell
        let row = indexPath.row
        if collectionView ==  cvEmojiRecent {
            let eightEmojis  = Constants.sharedInstance.RECENT_EMOJIS.suffix(8)
            var recentEmojis = Array(eightEmojis)
            recentEmojis = recentEmojis.reversed()
            emojiCell.imgEmoji.image = UIImage(named: recentEmojis[row])
        } else {
            emojiCell.imgEmoji.image = UIImage(named: "e_\(row + 1)")
        }
        
        return emojiCell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == cvEmojiRecent {
            let width = ( cvEmojiRecent.bounds.width * 0.8299 ) / 8
            return CGSize(width: width, height: width)
        } else {
            let width = ( cvEmojiMore.bounds.width * 0.7441 ) / 8
            return CGSize(width: width, height: width)
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        for i in 0..<viewEmojis.count {
            viewEmojis[i].backgroundColor = .clear
            viewEmojis[i].transform = CGAffineTransform.identity
            imgsEmojis[i].transform = CGAffineTransform.identity
        }
        UIView.animate(withDuration: 0.5) {
            self.viewMoreEmoji   .alpha = 0.0
            self.viewEmoji       .alpha = 0.0
            self.viewInviteFriend.alpha = 1.0
        }
        btnMyEmoji.isSelected = false
        if collectionView == cvEmojiMore {
            let emojiName     = "e_\(row + 1)"
            selectedEmojiName = emojiName
        } else {
            selectedEmojiName = recentEmojis[row]
        }
        if recentEmojis.count == 0 {
            recentEmojis.append(selectedEmojiName)
            Constants.sharedInstance.RECENT_EMOJIS = recentEmojis
        } else {
            var emojiFound  = false
            for (i,emoji) in recentEmojis.enumerated() {
                if emoji == selectedEmojiName {
                    recentEmojis.remove(at: i)
                    recentEmojis.append(selectedEmojiName)
                    emojiFound = true
                }
            }
            if !emojiFound {
                recentEmojis.append(selectedEmojiName)
            }
            Constants.sharedInstance.RECENT_EMOJIS = recentEmojis
        }
        cvEmojiRecent.reloadData()
        updateEmoji()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == cvEmojiRecent {
            return 0
        } else {
            let spacing = ( cvEmojiMore.bounds.width * 0.2559 ) / 8
            return spacing
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == cvEmojiMore {
            return ( cvEmojiMore.bounds.height * 0.1112 ) / 5
        } else {
            let spacing = ( cvEmojiRecent.bounds.width * 0.1701 ) / 8
            return spacing
        }
    }
}

extension HomeVC: AgoraRtcEngineDelegate{
    /// Initializes AgoraRtcEngineKit
    func initializeAgoraEngine() {
        agoraKit?.delegate = self
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: AGORA_APP_ID,
                                                  delegate: self)
    }
    /// join channel
    func joinChannel(token : String, channelId: String, uid : UInt){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0){
            self.agoraKit?.joinChannel(
                byToken     : token    ,
                channelId   : channelId,
                info        : nil      ,
                uid         : 0      ,
                joinSuccess : {
                    (channel, uid, elapsed)
                    in
                    self.agoraKit?.setEnableSpeakerphone(false)
                    UIApplication.shared.isIdleTimerDisabled = true
                    print("user joined using channel \(channel) with \(uid)")
                    Constants.sharedInstance.isWaiting       = false
                    self.isConnecting    = true
                    self.buttonStack.alpha = 1.0
                    self.waitTimer.invalidate()
                    self.startCalling()
                })
        }
    }
    
}
