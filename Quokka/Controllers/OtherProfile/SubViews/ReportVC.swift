//
//  ReportVC.swift
//  Quokka
//
//  Created by Muhammad Zubair on 04/03/2021.
//  Copyright © 2021 Codes Binary. All rights reserved.
//

import UIKit
import SwiftyJSON

class ReportVC: UIViewController {
    /* MARK:- OUTLETS */
    /// TextFields
    @IBOutlet weak var txtFieldOtherReason  : UITextField!
    /// Buttons
    @IBOutlet weak var btnSubmit            : UIButton!
    /// Outlet Collections
    @IBOutlet var btnOptions   : [UIButton]!
    @IBOutlet var viewsRoundx2 : [UIView]!
    @IBOutlet var viewsRoundx6 : [UIView]!
    
    /* MARK:- PROPERTIES */
    var userID       = ""
    var reportReason = ""
    
    /* MARK:- CLOSURES */
    var dismissPreviousVC       : (() -> Void)?
    /* MARK:- LIFE CYCLYE */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dismissPreviousVC?()
    }
    
}
/* MARK:- Methods */
extension ReportVC {
    func setupVC (){
        self.view.minFontSize()
        self.view.dismissKeyboard()
        layoutVC()
        addingTargetsToTextFields()
    }
    func layoutVC(){
        MAIN_DISPATCH.async { [unowned self] in
            for v in viewsRoundx2 {
                v.layer.cornerRadius = v.bounds.height / 2
            }
            for v in viewsRoundx6 {
                v.layer.cornerRadius = v.bounds.height / 6
            }
        }
    }
    func addingTargetsToTextFields(){
        txtFieldOtherReason.addTarget(
            self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
}
/* MARK:- OBJ-C Methods */
extension ReportVC {
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text != "" {
            for btn in btnOptions {
                btn.isSelected = false
            }
        }
    }
}
/* MARK:- ACTIONS */
extension ReportVC {
    @IBAction func optionTapped(_ sender : UIButton) {
        for btn in btnOptions {
            btn.isSelected = false
        }
        sender.isSelected = true
        reportReason = sender.accessibilityLabel!
        txtFieldOtherReason.text = ""
    }
    @IBAction func submitTapped(_ sender : UIButton) {
        let otherReason = txtFieldOtherReason.text!
        if otherReason != "" {
            reportReason = otherReason
        }
        if reportReason == "" {
            self.showToast(message: "Please select a reason..")
            return
        }
        reportUserApi()
    }
}
/* MARK:- API Methods */
extension ReportVC {
    func reportUserApi(){
        if !Reachability.isConnectedToNetwork() {
            self.showToast(message: "No Internet Connection!")
            return
        }
        var param = ["id" : userID]
        param["description"] = reportReason
        self.showSpinner(onView: btnSubmit , indicatorColor: .black)
        NetworkManager.sharedInstance.reportUser(param: param) { (response) in
            self.removeSpinner()
            switch response.result {
            case .success(_):
                do {
                    let apiData = try JSON(data: response.data!)
                    Helper.debugLogs(any: apiData)
                    let dataObj = apiData["data"]
                    let message = dataObj["message"].stringValue
                    if response.response?.statusCode == 200 {
                        self.showToast(message: "Admin will take action on you Report soon.")
                        self.showAlertDualAction(title: "Block", message: "You want to block this User?") { (comp) in
                            if comp {
                                self.blockUserApi()
                            } else {
                                self.dismiss(animated: true, completion: nil)
                            }
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
    func blockUserApi(){
        if !Reachability.isConnectedToNetwork() {
            self.showToast(message: "No Internet Connection!")
            return
        }
        let param = ["id" : userID]
        self.showSpinner(onView: self.view , indicatorColor: .black)
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
