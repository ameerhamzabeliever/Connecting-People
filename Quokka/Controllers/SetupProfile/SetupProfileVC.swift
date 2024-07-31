//
//  SetupProfileVC.swift
//  Quokka
//
//  Created by Muhammad Zubair on 31/12/2020.
//  Copyright © 2020 Codes Binary. All rights reserved.
//

import UIKit
import SwiftyJSON

class SetupProfileVC: UIViewController {
    
    /* MARK:- Outlets */
    /// Views
    @IBOutlet weak var viewUsername       : UIView!
    @IBOutlet weak var viewDOB            : UIView!
    @IBOutlet weak var viewQuestions      : UIView!
    @IBOutlet weak var viewUContinue      : UIView!
    @IBOutlet weak var viewDContinue      : UIView!
    @IBOutlet weak var viewQContinue      : UIView!
    /// Labels
    @IBOutlet weak var lblAvailable       : UILabel!
    @IBOutlet weak var lblQuestion        : UILabel!
    @IBOutlet weak var lblQuesNumber      : UILabel!
    
    /// TextFields
    @IBOutlet weak var txtFieldUsername   : UITextField!
    @IBOutlet weak var txtFieldDOB        : UITextField!
    @IBOutlet weak var txtFieldAnswer     : UITextField!
    /// Progress View
    @IBOutlet weak var progressBar        : UIProgressView!
    /// Buttons
    @IBOutlet weak var btnUContinue       : UIButton!
    @IBOutlet weak var btnDContinue       : UIButton!
    @IBOutlet weak var btnQContinue       : UIButton!
    
    /// ImageViews
    @IBOutlet weak var imgUsernameVerifed : UIImageView!
    /// Outet Collections
    @IBOutlet var viewsRound              : [UIView]!
    
    /* MARK:- Properties */
    let datePicker   = UIDatePicker()
    var answersArray : [String] = []
    var isVerifed    : Bool     = false
    var currentIndex : Int      = 0
    /// Api Varialables
    var userName     : String   = ""
    var dob          : String   = ""
    
    /* MARK:- LifeCycle */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
    }
}

/* MARK:- Methods */
extension SetupProfileVC {
    func setupVC (){
        self.view.minFontSize()
        self.view.dismissKeyboard()
        layoutVC()
        showDatePicker()
        addingTargetsToTextFields()
    }
    func layoutVC(){
        MAIN_DISPATCH.async { [unowned self] in
            for v in viewsRound {
                v.layer.cornerRadius = v.bounds.height / 2
            }
        }
    }
    func addingTargetsToTextFields(){
        txtFieldUsername.addTarget(
            self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        txtFieldDOB.addTarget(
            self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        txtFieldAnswer.addTarget(
            self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    func showDatePicker(){
        //Formate Date
        datePicker.datePickerMode = .date
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        txtFieldDOB.inputAccessoryView = toolbar
        txtFieldDOB.inputView          = datePicker
        
    }
    func userNameAvailable(){
        imgUsernameVerifed.image     = UIImage(named: "tick")
        lblAvailable      .text      = "Yes! \"\(userName)\" is available"
        lblAvailable      .textColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        UIView.animate(withDuration: 0.4) {
            self.lblAvailable      .alpha = 1.0
            self.imgUsernameVerifed.alpha = 1.0
        }
        MAIN_DISPATCH.asyncAfter(deadline: .now() + 1.0) { [unowned self] in
            setDOBView()
        }
    }
    func userNameNotAvailable(){
        imgUsernameVerifed.image = UIImage(named: "cross")
        lblAvailable      .text      = "Sorry! \"\(userName)\" is not available"
        lblAvailable      .textColor = .red
        UIView.animate(withDuration: 0.4) {
            self.lblAvailable      .alpha = 1.0
            self.imgUsernameVerifed.alpha = 1.0
        }
        userName = ""
    }
    func setDOBView(){
        UIView.animate(withDuration: 0.4) {
            self.viewUsername.alpha = 0.0
            self.viewDOB     .alpha = 1.0
        }
    }
    func setQuestionView(){
        dob = txtFieldDOB.text!
        UIView.animate(withDuration: 0.4) {
            self.viewDOB      .alpha = 0.0
            self.viewQuestions.alpha = 1.0
        }
        setQuestion()
    }
    func setQuestion(){
        txtFieldAnswer.text = ""
        lblQuestion   .text = QUESTIONS[currentIndex]
        lblQuesNumber .text = "\(currentIndex + 1)/\(QUESTIONS.count)"
        txtFieldAnswer.placeholder = QUESTION_SUGGESTIONS[currentIndex]
        viewQContinue .alpha = 0.4
        btnQContinue  .isUserInteractionEnabled = false
    }
    func proceedToHome() {
        let homeVC = HomeVC(
            nibName: Constants.VCNibs.HOME,
            bundle : nil
        )
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
}
/* MARK:- OBJ-C Methods */
extension SetupProfileVC {
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.accessibilityLabel == "Username" {
            if textField.text == "" {
                self.lblAvailable      .alpha = 0.0
                self.imgUsernameVerifed.alpha = 0.0
                viewUContinue.alpha = 0.4
                btnUContinue.isUserInteractionEnabled = false
            } else {
                viewUContinue.alpha = 1
                btnUContinue.isUserInteractionEnabled = true
            }
        } else if textField.accessibilityLabel == "DOB" {
            if textField.text == "" {
                viewDContinue.alpha = 0.4
                btnDContinue.isUserInteractionEnabled = false
            } else {
                viewDContinue.alpha = 1
                btnDContinue.isUserInteractionEnabled = true
            }
        } else if textField.accessibilityLabel == "Question" {
            if textField.text == "" {
                viewQContinue.alpha = 0.4
                btnQContinue.isUserInteractionEnabled = false
            } else {
                viewQContinue.alpha = 1
                btnQContinue.isUserInteractionEnabled = true
            }
        }
    }
    @objc func donedatePicker(){
        let formatter        = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy"
        txtFieldDOB.text     = formatter.string(from: datePicker.date)
        viewDContinue.alpha  = 1
        btnDContinue.isUserInteractionEnabled = true
        self.view.endEditing(true)
    }
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
}
/* MARK:- Actions */
extension SetupProfileVC {
    @IBAction func ContinueTapped(_ sender : UIButton){
        if userName == "" {
            checkUsername()
        } else if dob == "" {
            setQuestionView()
        } else {
            currentIndex += 1
            answersArray.append(txtFieldAnswer.text!)
            if currentIndex >= QUESTIONS.count {
                updateProfile()
            } else {
                setQuestion()
            }
        }
    }
    @IBAction func skipTapped(_ sender : UIButton){
        currentIndex += 1
        answersArray.append("")
        if currentIndex >= QUESTIONS.count {
            updateProfile()
        } else {
            setQuestion()
        }
    }
}
/* MARK:- Api Methods */
extension SetupProfileVC {
    func checkUsername(){
        if !Reachability.isConnectedToNetwork() {
            self.showToast(message: "No Internet Connection!")
            return
        }
        userName = txtFieldUsername.text!
        let param : [String : Any] = ["userName" : userName]
        self.showSpinner(onView: self.viewUContinue, identifier: "UContinue", title: "")
        NetworkManager.sharedInstance.checkUsername(param: param) {
            (response) in
            self.removeSpinner(identifier: "UContinue")
            switch response.result {
            case .success(_):
                do {
                    let apiData = try JSON(data: response.data!)
                    Helper.debugLogs(any: apiData)
                    let dataObj = apiData["data"]
                    let message = dataObj["message"].stringValue
                    if response.response?.statusCode == 200 {
                        self.userNameAvailable()
                    } else if response.response?.statusCode == 201 {
                        self.userNameNotAvailable()
                    } else if response.response?.statusCode == 401 {
                        self.showToast(message: "UnAuthorized : User Not Found")
                        self.logoutUser()
                    } else {
                        self.showToast(message: message)
                    }
                } catch {
                    self.showToast(message: response.error?.localizedDescription ?? "Something went wrong")
                }
            case .failure(_):
                self.showToast(message: "Something went wrong with Servers")
            }
        }
    }
    func updateProfile(){
        if !Reachability.isConnectedToNetwork() {
            self.showToast(message: "No Internet Connection!")
            return
        }
        var updateParam : [String : Any] = [:]
        updateParam["userName"] = userName
        updateParam["age"]      = dob
        updateParam["profile_answers"] = answersArray
        self.showSpinner(onView: self.viewQContinue, identifier: "QContinue",title: "")
        NetworkManager.sharedInstance.updateProfile(param: updateParam) { (response) in
            self.removeSpinner(identifier: "QContinue")
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
                        self.proceedToHome()
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

