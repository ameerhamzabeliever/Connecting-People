//
//  LoginVC.swift
//  Quokka
//
//  Created by Muhammad Zubair on 19/11/2020.
//  Copyright © 2020 Codes Binary. All rights reserved.
//

import UIKit
import SwiftyJSON
import SCSDKLoginKit
import AuthenticationServices

class LoginVC: UIViewController {
    
    /* MARK:- Outlets */
    /// Views
    @IBOutlet weak var viewSnapChat    : UIView!
    @IBOutlet weak var viewSnapChatBtn : UIView!
    @IBOutlet weak var viewAppleBtn    : UIView!
    /// Constraints
    @IBOutlet weak var conslblWannaChatTop : NSLayoutConstraint!
    
    /* MARK:- Properties */
    var loginParam : [String : Any] = [:]
    var appleParam : [String : Any] = [:]
    var appleUserId   = ""
    
    /* MARK:- LifeCycle */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
    }
}
/* MARK:- Methods */
extension LoginVC {
    func setupVC(){
        self.view.minFontSize()
        layoutVC()
    }
    func layoutVC(){
        MAIN_DISPATCH.async { [self] in
            viewSnapChat   .layer.cornerRadius = viewSnapChat   .bounds.height / 6.7
            viewSnapChatBtn.layer.cornerRadius = viewSnapChatBtn.bounds.height / 2
            viewAppleBtn   .layer.cornerRadius = viewAppleBtn   .bounds.height / 2
            if SCREEN_HEIGHT < 737 {
                conslblWannaChatTop.constant = 7
            }
        }
    }
    func proceedToHome() {
        let homeVC = HomeVC(
            nibName: Constants.VCNibs.HOME,
            bundle : nil
        )
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
    func proceedToSetup(){
        let setupVC = SetupProfileVC(
            nibName: Constants.VCNibs.SETUP_PROFILE,
            bundle : nil
        )
        self.navigationController?.pushViewController(setupVC, animated: true)
    }
    func fetchUserInfo() {
        if !Reachability.isConnectedToNetwork() {
            self.showToast(message: "No Internet Connection!")
            return
        }
        let graphQLQuery = "{me{externalId, displayName, bitmoji{avatar}}}"
        let variables = ["page": "bitmoji"]
    
        SCSDKLoginClient.fetchUserData(
            withQuery: graphQLQuery,
            variables: variables,
            success  : { (resources: [AnyHashable: Any]?) in
                
            MAIN_DISPATCH.async {
                self.showSpinner(onView: self.viewSnapChatBtn,indicatorColor: .black)
            }
            guard let resources = resources,
                  let data = resources["data"] as? [String: Any],
                  let me = data["me"] as? [String: Any] else { return }
            
            let displayName = me["displayName"] as! String
            let externalId  = me["externalId"] as! String
            self.loginParam["name"] = displayName
            self.loginParam["unique_id"] = externalId
            if let bitmoji = me["bitmoji"] as? [String : Any] {
                if let avatarUrl = bitmoji["avatar"] as? String {
                    self.loginParam["avatar"] = avatarUrl
                } else {
                    self.loginParam["avatar"] = ""
                }
            } else {
                self.loginParam["avatar"] = ""
            }
            self.loginParam["deviceId"] = UIDevice.current.identifierForVendor!.uuidString
            self.loginSignUp(param: self.loginParam)
        }, failure: { (error: Error?, isUserLoggedOut: Bool) in
            if isUserLoggedOut {
                self.snapChatLogin()
            } else {
                self.showToast(message: error?.localizedDescription ?? "Something went wrong")
            }
        })
    }
    func snapChatLogin(){
        if !Reachability.isConnectedToNetwork() {
            self.showToast(message: "No Internet Connection!")
            return
        }
        SCSDKLoginClient.login(from: self.navigationController!) { (success: Bool, error: Error?) in
            if success {
                self.fetchUserInfo()
            }
            if let error = error {
                print("Login failed. Details: \(error.localizedDescription)")
            }
        }
    }
    func loginWithAppleID(){
        // Check Credential State
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: appleUserId) {  (credentialState, error) in
            switch credentialState {
            case .authorized:
                // The Apple ID credential is valid.
                if self.appleUserId != "" {
                    if Constants.sharedInstance.USER_NAME == "" {
                        self.appleParam = [:]
                        self.appleParam["unique_id"] = self.appleUserId
                        self.appleParam["deviceId"]  = UIDevice.current.identifierForVendor!.uuidString
                        self.appleSignup(param: self.appleParam)
                    }
                    else{
                        self.appleParam["name"]      = Constants.sharedInstance.USER_NAME
                        self.appleParam["unique_id"] = self.appleUserId
                        self.appleParam["avatar"]    = ""
                        self.appleParam["deviceId"]  = UIDevice.current.identifierForVendor!.uuidString
                        self.loginSignUp(param: self.appleParam)
                    }
                }
                break
            case .revoked:
                // The Apple ID credential is revoked.
                self.showToast(message: "The Apple ID credential is revoked.")
                break
            case .notFound:
                // Existing Account Setup Flow
                self.handleAppleIdRequest()
                break
            default:
                self.showToast(message: String(describing: error?.localizedDescription))
                break
            }
        }
    }
    // Existing Account Setup Flow
    @objc func handleAppleIdRequest() {
        
        let appleSignInRequest = ASAuthorizationAppleIDProvider().createRequest()
        // set scope
        appleSignInRequest.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [appleSignInRequest])
        // set delegate
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}
/* MARK:- Actions */
extension LoginVC {
    @IBAction func snapChatTapped(_ sender : UIButton) {
        fetchUserInfo()
    }
    @IBAction func appleLoginTapped(_ sender: UIButton){
        loginWithAppleID()
    }
    @IBAction func privacyTapped(_ sender : UIButton) {
        if let url = URL(string: "https://www.hiquokka.com/privacy/"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    @IBAction func termsTapped(_ sender : UIButton) {
        if let url = URL(string: "https://www.hiquokka.com/terms/"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    @IBAction func agreementTapped(_ sender : UIButton) {
        if let url = URL(string: "https://www.hiquokka.com/anti-bullying/"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
}
/* MARK:- API Methods */
extension LoginVC {
    func loginSignUp(param : [String: Any]) {
        if !Reachability.isConnectedToNetwork() {
            self.showToast(message: "No Internet Connection!")
            return
        }
        NetworkManager.sharedInstance.logIn(param: param) { (response) in
            MAIN_DISPATCH.async {
                self.removeSpinner()
            }
            switch response.result {
            case .success(_):
                do {
                    let apiData = try JSON(data: response.data!)
                    Helper.debugLogs(any: apiData)
                    let dataObj = apiData["data"]
                    if response.response?.statusCode == 200 {
                        let token   = "Bearer \(dataObj["token"].stringValue)"
                        let userObj = dataObj["user"]
                        DEFAULTS.set(token, forKey: Constants.userDefaults.HTTP_HEADERS)
                        Constants.sharedInstance.USER = UserModel(json: userObj)
                        if Constants.sharedInstance.USER?.userName == "" {
                            self.proceedToSetup()
                        } else {
                            self.proceedToHome()
                        }
                    } else {
                        let errorMessage = dataObj["error"].stringValue
                        self.showToast(message: errorMessage)
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
    func appleSignup(param : [String: Any]) {
        if !Reachability.isConnectedToNetwork() {
            self.showToast(message: "No Internet Connection!")
            return
        }
        NetworkManager.sharedInstance.logIn_Apple(param: param) { (response) in
            switch response.result {
            case .success(_):
                do {
                    let apiData = try JSON(data: response.data!)
                    Helper.debugLogs(any: apiData)
                    let dataObj = apiData["data"]
                    if response.response?.statusCode == 200 {
                        let token   = "Bearer \(dataObj["token"].stringValue)"
                        let userObj = dataObj["user"]
                        DEFAULTS.set(token, forKey: Constants.userDefaults.HTTP_HEADERS)
                        Constants.sharedInstance.USER = UserModel(json: userObj)
                        if Constants.sharedInstance.USER?.userName == "" {
                            self.proceedToSetup()
                        } else {
                            self.proceedToHome()
                        }
                    } else {
                        let errorMessage = dataObj["error"].stringValue
                        self.showToast(message: errorMessage)
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
}
// MARK: - Delegate Methods
extension LoginVC: ASAuthorizationControllerDelegate,ASAuthorizationControllerPresentationContextProviding {
    // ASAuthorizationController Presentation Context Providing
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    // Handle ASAuthorizationController Delegate and Presentation Context
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredentials = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        self.appleUserId = appleIDCredentials.user
        if let fullname = appleIDCredentials.fullName {
            if fullname.givenName != nil {
                Constants.sharedInstance.USER_NAME = "\(fullname.givenName!) \(fullname.familyName!)"
            } else {
                showToast(message: "Something wrong with Apple credentials.")
    //            return
            }
        }
        if let identityTokenData = appleIDCredentials.identityToken,
            let identityTokenString = String(data: identityTokenData, encoding: .utf8) {
            print("Identity Token \(identityTokenString)")
        }
        if appleUserId != "" {
            if Constants.sharedInstance.USER_NAME == "" {
                self.appleParam = [:]
                self.appleParam["unique_id"] = appleUserId
                self.appleParam["deviceId"]  = UIDevice.current.identifierForVendor!.uuidString
                self.appleSignup(param: appleParam)
            }
            else{
                self.appleParam["name"]      = Constants.sharedInstance.USER_NAME
                self.appleParam["unique_id"] = appleUserId
                self.appleParam["avatar"]    = ""
                self.appleParam["deviceId"]  = UIDevice.current.identifierForVendor!.uuidString
                self.loginSignUp(param: self.appleParam)
            }
        }
    }
    // Handle ASAuthorizationController Delegate and Presentation Context
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
    }
}
