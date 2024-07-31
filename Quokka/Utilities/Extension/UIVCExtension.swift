//
//  UIVCExtension.swift
//  Quokka
//
//  Created by Muhammad Zubair on 08/12/2020.
//  Copyright © 2020 Codes Binary. All rights reserved.
//

import Foundation
import UIKit
import DTOverlayController

extension UIViewController {
    func showAlert(title: String = APP_NAME, message: String) {
        
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let oKAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil
        )
        
        alertController.addAction(oKAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    func showAlertWithAction(
        title: String = APP_NAME,
        message: String,
        completion: @escaping(_ isCompleted: Bool)->()
    ) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "Ok", style: .default) { (OkAction) in
            completion(true)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func showAlertDualAction(
        title: String = APP_NAME,
        message: String,
        completion: @escaping(_ isCompleted: Bool)->()
    ) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let yesAction = UIAlertAction(
            title: "Yes",
            style: .default
        ) { (OkAction) in
            completion(true)
        }
        let noAction = UIAlertAction(
            title: "No",
            style: .destructive
            ) { (NoAction) in
            completion(false)
        }
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func showToast(message : String) {
        DispatchQueue.main.async {
            var toastLabel = UILabel()
            toastLabel = UILabel(frame: CGRect(x: 0 , y: self.view.bounds.height - 40, width: self.view.bounds.width, height: 30 ))
            toastLabel.backgroundColor = #colorLiteral(red: 0.2605186105, green: 0.2605186105, blue: 0.2605186105, alpha: 1)
            toastLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            toastLabel.textAlignment = .center;
            toastLabel.text = message
            toastLabel.alpha = 1.0
            toastLabel.clipsToBounds  =  true
            self.view.addSubview(toastLabel)
            UIView.animate(withDuration: 2.0, delay: 3.0, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }, completion: {(isCompleted) in
                toastLabel.removeFromSuperview()
            })
        }
    }
    func showSpinner(
        onView          : UIView,
        identifier      : String  = "Default",
        title           : String  = ""       ,
        backgroundColor : UIColor = .clear   ,
        indicatorColor  : UIColor = .white   ,
        textColor       : UIColor = .white
    ) {
        let spinnerView = UIView.init(
            frame: onView.bounds
        )
        spinnerView.backgroundColor = backgroundColor
        var activityIndicator = UIActivityIndicatorView()
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = indicatorColor
        activityIndicator.startAnimating()
        activityIndicator.center = spinnerView.center
        let lableY = activityIndicator.frame.origin.y + activityIndicator.frame.size.height
        let lableWidth = spinnerView.frame.width
        let label = UILabel(
            frame: CGRect(
                x      : 0.0       ,
                y      : lableY    ,
                width  : lableWidth,
                height : 40
            )
        )
        label.textColor     = textColor
        label.text          = title
        label.textAlignment = .center
        label.font          = UIFont(name: "Avenir Next Bold", size: 14.0)
        DispatchQueue.main.async {
            spinnerView.addSubview(label)
            spinnerView.addSubview(activityIndicator)
            onView.addSubview(spinnerView)
        }
        spinnerView.accessibilityIdentifier = identifier
        SPINNERS.append(spinnerView)
    }
    func removeSpinner(identifier: String = "Default") {
        DispatchQueue.main.async {
            for (index, spinner) in SPINNERS.enumerated() {
                if spinner.accessibilityIdentifier == identifier {
                    spinner.removeFromSuperview()
                    if SPINNERS.indices.contains(index){
                        SPINNERS.remove(at: index)
                    }
                }
            }
        }
    }
    func backToHome(){
        if let viewControllers = self.navigationController?.viewControllers {
            var vcNotFound                    = true
            Constants.sharedInstance.isLogout = false
            for vc in viewControllers {
                if vc.isKind(of: LoginVC.self) {
                    vcNotFound = false
                    self.navigationController?.popToViewController(vc, animated: true)
                }
            }
            if vcNotFound {
                let loginVC = LoginVC(nibName: Constants.VCNibs.LOGIN, bundle: nil)
                self.navigationController?.pushViewController(loginVC, animated: true)
            }
        }
        else {
            self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
        }
    }
    func logoutUser(){
        Constants.sharedInstance.USER     = nil
        Constants.sharedInstance.isLogout = true
        backToHome()
    }
    func topMostViewController() -> UIViewController {
        
        if let presented = self.presentedViewController {
            return presented.topMostViewController()
        }
        
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }
        
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        
        return self
    }
    func saveKeyboardHeightGlobaly() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight    = keyboardRectangle.height
            KEYBOARD_HEIGHT       = keyboardHeight
            if let profileReference = Constants.sharedInstance.PROFILE_VC_REFERENCE {
                profileReference.setupResponseView()
            }
        }
    }
}

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return self.keyWindow?.rootViewController?.topMostViewController()
    }
}
