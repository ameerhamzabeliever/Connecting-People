//
//  FeedbackVC.swift
//  Quokka
//
//  Created by Muhammad Zubair on 12/12/2020.
//  Copyright © 2020 Codes Binary. All rights reserved.
//

import UIKit
import SwiftyJSON

class FeedbackVC: UIViewController {
    
    /* MARK:- Outlets */
    /// Constraints
    @IBOutlet weak var consBtnNextBottom : NSLayoutConstraint!
    /// Label
    @IBOutlet weak var lblAddFriend      : UILabel!
    @IBOutlet weak var lblUserName       : UILabel!
    /// ImageViews
    @IBOutlet weak var imgProfile         : UIImageView!
    /// TextViews
    @IBOutlet weak var txtViewQuestion   : UITextView!
    @IBOutlet weak var txtViewFeedback   : UITextView!
    /// TextFields
    @IBOutlet weak var txtFieldAnswer    : UITextField!
    /// Progress View
    @IBOutlet weak var progressBar       : UIProgressView!
    /// Views
    @IBOutlet weak var viewBtnNext        : UIView!
    @IBOutlet weak var viewCompleted      : UIView!
    @IBOutlet weak var viewFriendMain     : UIView!
    @IBOutlet weak var viewFriend         : UIView!
    @IBOutlet weak var viewAcceptFriend   : UIView!
    @IBOutlet weak var viewPendingRequest : UIView!
    @IBOutlet weak var viewAddFriend      : UIView!
    @IBOutlet weak var viewBlocked        : UIView!
    @IBOutlet weak var viewUnBlocked      : UIView!
    /// Buttons
    @IBOutlet weak var btnNext           : UIButton!
    /// Outet Collections
    @IBOutlet var viewsRound             : [UIView]!
    /* MARK:- Properties */
    var feedbackArray   : [String] = []
    var feedbackAnswers : [String] = []
    var feedback = [[],[]]
    var otherUser     : UserModel?
    var userStatus    : String = ""
    var requestStatus : String = ""
    var review        : String = ""
    var callId        : String = ""
    var currentQuestion = 0
    var paramQues : [String] = []
    var paramAns  : [String] = []
    /* MARK:- LifeCycle */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
    }
    
}
/* MARK:- Methods */
extension FeedbackVC {
    func setupVC(){
        self.view.minFontSize()
        feedbackArray = Constants.sharedInstance.FEEDBACK_QUESTIONS
        txtViewFeedback.placeholder = "Write something about..."
        setQuestion()
        loadData()
        layoutVC()
        keyBoardObservers()
        txtFieldAnswer.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        txtFieldAnswer.becomeFirstResponder()
        txtViewFeedback.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
    }
    func loadData(){
        setupFriend()
    }
    func layoutVC(){
        MAIN_DISPATCH.async { [self] in
            for v in viewsRound {
                v.layer.cornerRadius = v.bounds.height / 2
            }
            self.viewFriendMain.layer.cornerRadius = self.viewFriendMain.bounds.height / 6
            self.txtViewFeedback.layer.cornerRadius = 20.0
            self.txtFieldAnswer.attributedPlaceholder = NSAttributedString(
                string     : "Start Writing",
                attributes : [NSAttributedString.Key.foregroundColor: UIColor.gray]
            )
        }
    }
    func setupFriend(){
        if let userObj = otherUser {
            lblAddFriend.text = "Wanna add \(userObj.displayName) as a friend?"
            lblUserName .text = userObj.displayName
            Helper.setImage(imageView: imgProfile, imageUrl: userObj.avatarUrl, placeholder: "Quokka-Placeholder")
            switch userStatus {
            case "Add":
                viewFriend        .alpha = 0.0
                viewAcceptFriend  .alpha = 0.0
                viewPendingRequest.alpha = 0.0
                viewAddFriend     .alpha = 1.0
                viewBlocked       .alpha = 0.0
                viewUnBlocked     .alpha = 0.0
                txtViewFeedback   .alpha = 0.0
            case "Friends" :
                viewFriend        .alpha = 1.0
                viewAcceptFriend  .alpha = 0.0
                viewPendingRequest.alpha = 0.0
                viewAddFriend     .alpha = 0.0
                viewBlocked       .alpha = 0.0
                viewUnBlocked     .alpha = 0.0
                txtViewFeedback   .alpha = 1.0
            case "Pending" :
                viewFriend        .alpha = 0.0
                viewAcceptFriend  .alpha = 0.0
                viewPendingRequest.alpha = 1.0
                viewAddFriend     .alpha = 0.0
                viewBlocked       .alpha = 0.0
                viewUnBlocked     .alpha = 0.0
                txtViewFeedback   .alpha = 1.0
            case "Accept" :
                viewFriend        .alpha = 0.0
                viewAcceptFriend  .alpha = 1.0
                viewPendingRequest.alpha = 0.0
                viewAddFriend     .alpha = 0.0
                viewBlocked       .alpha = 0.0
                viewUnBlocked     .alpha = 0.0
                txtViewFeedback   .alpha = 1.0
            case "UnBlock" :
                viewFriend        .alpha = 0.0
                viewAcceptFriend  .alpha = 0.0
                viewPendingRequest.alpha = 0.0
                viewAddFriend     .alpha = 0.0
                viewBlocked       .alpha = 0.0
                viewUnBlocked     .alpha = 1.0
                txtViewFeedback   .alpha = 1.0
            case "Blocked" :
                viewFriend        .alpha = 0.0
                viewAcceptFriend  .alpha = 0.0
                viewPendingRequest.alpha = 0.0
                viewAddFriend     .alpha = 0.0
                viewBlocked       .alpha = 1.0
                viewUnBlocked     .alpha = 0.0
                txtViewFeedback   .alpha = 1.0
            default:
                break
            }
        }
    }
    func keyBoardObservers() {
        self.view.dismissKeyboard()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func setQuestion(){
        let floatIndex      = Float(self.currentQuestion)
        let floatTotalIndex = Float(self.feedbackArray.count)
        self.progressBar.setProgress( (floatIndex/floatTotalIndex), animated: true)
        
        if currentQuestion == feedbackArray.count {
            txtFieldAnswer.resignFirstResponder()
            UIView.animate(withDuration: 0.3) {
                self.viewCompleted.alpha = 1.0
            }
        } else {
            UIView.animate(withDuration: 0.5) {
                self.txtViewQuestion.alpha = 0.0
                self.txtFieldAnswer .alpha = 0.0
            }
            self.txtViewQuestion.text  = self.feedbackArray[self.currentQuestion]
            self.txtFieldAnswer .text  = ""
            self.viewBtnNext    .alpha = 0.5
            self.btnNext.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.5) {
                self.txtViewQuestion.alpha = 1.0
                self.txtFieldAnswer .alpha = 1.0
            }
            currentQuestion += 1
        }
    }
}
/* MARK:- OBJ-C Methods */
extension FeedbackVC {
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if consBtnNextBottom.constant != 40 + keyboardSize.height {
                UIView.animate(withDuration: 0.1) {
                    self.consBtnNextBottom.constant += keyboardSize.height
                }
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.1) {
            self.consBtnNextBottom.constant = 40
        }
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text == "" {
            viewBtnNext.alpha = 0.5
            btnNext.isUserInteractionEnabled = false
        } else {
            viewBtnNext.alpha = 1
            btnNext.isUserInteractionEnabled = true
        }
    }
}

/* MARK:- Actions */
extension FeedbackVC {
    @IBAction func nextTapped(_ sender : UIButton){
        feedbackAnswers.append(txtFieldAnswer.text!)
        setQuestion()
    }
    @IBAction func continueTapped(_ sender : UIButton){
        submitReview()
        review = txtViewFeedback.text
        if let textView = txtViewFeedback{
            if textView.text != ""{
                giveReview()
            }
        }
        for controller in self.navigationController!.viewControllers {
            if controller.isKind(of: HomeVC.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    @IBAction func pendingTapped(_ sender : UIButton){
        requestStatus = "Sent"
        cancelRequestApi()
    }
    @IBAction func addTapped(_ sender : UIButton){
        addFriendApi()
    }
    @IBAction func cancelTapped(_ sender : UIButton){
        requestStatus = "Received"
        cancelRequestApi()
    }
    @IBAction func acceptTapped(_ sender : UIButton){
        acceptFriendApi()
    }
}

/* MARK:- APIs */
extension FeedbackVC{
    func submitReview(){
        var parameters : [String : Any] = [:]
        parameters["callId"]   = callId
        for index in 0..<feedbackArray.count{
            let ques = "question"
            let ans  = "answer"
            paramQues.append(ques)
            paramAns.append(ans)
            let questionFeedback = [paramQues[index]: feedbackArray[index]]
            let answerFeedback   = [paramAns[index]: feedbackAnswers[index]]
            let feedback_Obj = [questionFeedback, answerFeedback]
            feedback.append(feedback_Obj)
        }
        parameters["feedback"] = feedback
        self.showSpinner(onView: self.view, indicatorColor: .black)
        NetworkManager.sharedInstance.saveFeedback(param: parameters){
            (response) in
            self.removeSpinner()
            switch response.result {
            case .success(_):
                do {
                    let apiData = try JSON(data: response.data!)
                    Helper.debugLogs(any: apiData)
                    let dataObj = apiData["data"]
                    let message = dataObj["message"].stringValue
                    if response.response?.statusCode == 200{
                        print("Saved Data succesfully")
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
    func addFriendApi(){
        if let user = otherUser {
            let param = ["id" : user.id]
            
            self.showSpinner(onView: self.view , indicatorColor: .black)
            NetworkManager.sharedInstance.addFriend(param: param){
                (response) in
                self.removeSpinner()
                switch response.result {
                case .success(_):
                    do {
                        let apiData = try JSON(data: response.data!)
                        Helper.debugLogs(any: apiData)
                        let dataObj = apiData["data"]
                        let message = dataObj["message"].stringValue
                        if response.response?.statusCode == 200{
                            print("success")
                            self.userStatus = "Pending"
                            self.setupFriend()
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
    func acceptFriendApi(){
        if let user = otherUser{
            let param = ["id" : user.id]
            self.showSpinner(onView: self.view , indicatorColor: .black)
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
                            print("Success")
                            self.userStatus = "friends"
                            self.setupFriend()
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
    func cancelRequestApi(){
        var param : [String : Any] = [ : ]
        if let user = otherUser{
            param = ["id": user.id]
            param = ["type" : requestStatus]
            self.showSpinner(onView: self.view , indicatorColor: .black)
            NetworkManager.sharedInstance.cancelFriend(param: param){(response) in
                self.removeSpinner()
                switch response.result{
                case .success(_):
                    do {
                        let apiData = try JSON(data: response.data!)
                        Helper.debugLogs(any: apiData)
                        let dataObj = apiData["data"]
                        let message = dataObj["message"].stringValue
                        if response.response?.statusCode == 200 {
                            print("Success")
                            self.userStatus = "Add"
                            self.setupFriend()
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
    func giveReview(){
        var param : [String : Any] = [ : ]
        if let user = otherUser{
            param["userId"] =  user.id
            param["review"] =  review
            self.showSpinner(onView: self.view , indicatorColor: .black)
            NetworkManager.sharedInstance.giveReview(param: param){(response) in
                self.removeSpinner()
                switch response.result{
                case .success(_):
                    do {
                        let apiData = try JSON(data: response.data!)
                        Helper.debugLogs(any: apiData)
                        let dataObj = apiData["data"]
                        let message = dataObj["message"].stringValue
                        if response.response?.statusCode == 200 {
                            print("Success")
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
}

extension UITextView: UITextViewDelegate {
    /// Resize the placeholder when the UITextView bounds change
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    /// The UITextView placeholder text
    public var placeholder: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }
    
    /// When the UITextView did change, show or hide the label based on if the UITextView is empty or not
    ///
    /// - Parameter textView: The UITextView that got updated
    public func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = !self.text.isEmpty
        }
    }
    
    /// Resize the placeholder UILabel to make sure it's in the same position as the UITextView text
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX = self.textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top - 2
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height
            
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    /// Adds a placeholder UILabel to this UITextView
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()
        
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.tag = 100
        
        placeholderLabel.isHidden = !self.text.isEmpty
        
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
        self.delegate = self
    }
}
