//
//  ProfileQuestionDelegate.swift
//  Quokka
//
//  Created by Muhammad Zubair on 15/01/2021.
//  Copyright © 2021 Codes Binary. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit

class ProfileQuestionDataController: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    /* MARK:- Questions Collection */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return QUESTIONS.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let questionCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CVCELLS.PROFILE_QUESTION, for: indexPath) as! ProfileQuestionCell
        let row = indexPath.row
        questionCell.lblQuestion.text = QUESTIONS[row]
        questionCell.currentIndex = row
        if let userObj = Constants.sharedInstance.USER {
            if userObj.profileAnswers.indices.contains(row) && userObj.profileAnswers[row] != "" {
                questionCell.txtViewResponse .text = userObj.profileAnswers[row]
            } else {
                questionCell.txtViewResponse.text = "Add Response.."
            }
        } else {
            let topMostViewController = UIApplication.shared.topMostViewController()
            topMostViewController?.logoutUser()
        }
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        longPressRecognizer  .accessibilityLabel = "\(row)"
        longPressRecognizer  .minimumPressDuration = 0.5
        questionCell.viewMain.addGestureRecognizer(longPressRecognizer)
        return questionCell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height
        let text   = QUESTIONS[indexPath.row]
        /// Getting width according to size of String
        let width  = text.size(
            withAttributes : [
                NSAttributedString.Key.font : UIFont(
                    name : "Apercu Pro Medium",
                    size : 18.0) ?? .systemFont(ofSize: 18.0)
            ]).width
        return CGSize(width: width + 32, height: height)
    }
}
/* MARK:- OBJ-C Methods */
extension ProfileQuestionDataController {
    @objc func longPressed(sender : UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began {
            if let profileVC = Constants.sharedInstance.PROFILE_VC_REFERENCE {
                profileVC.cvQuestions.visibleCells.forEach { (cell) in
                    let cell = cell as! ProfileQuestionCell
                    resetCell(cell, profileVC, isCancel: true)
                }
                let row = Int(sender.accessibilityLabel!)!
                setResponseCell(profileReference: profileVC, index: row)
                
            }
        }
    }
    @objc func saveTapped(_ sender: UIButton){
        let row         = sender.tag
        let profileVC   = Constants.sharedInstance.PROFILE_VC_REFERENCE!
        let currentCell = profileVC.cvQuestions.cellForItem(
            at: IndexPath(
                row     : row,
                section : 0)
        ) as! ProfileQuestionCell
        updateProfile(response: currentCell.txtViewResponse.text, index: row)
        resetCell(currentCell,profileVC)
    }
    @objc func cancelTapped(_ sender: UIButton){
        let row         = sender.tag
        let profileVC   = Constants.sharedInstance.PROFILE_VC_REFERENCE!
        let currentCell = profileVC.cvQuestions.cellForItem(
            at: IndexPath(
                row     : row,
                section : 0)
        ) as! ProfileQuestionCell
        resetCell(currentCell, profileVC, isCancel: true)
    }
}
/* MARK:- Methods */
extension ProfileQuestionDataController {
    func resetCell(
        _ cell             : ProfileQuestionCell,
        _ profileReference : ProfileVC          ,
        isCancel           : Bool = false
    ){
        cell.txtViewResponse.isEditable   = false
        cell.txtViewResponse.isSelectable = false
        cell.txtViewResponse.resignFirstResponder()
        UIView.animate(withDuration: 0.2) {
            profileReference.viewResponse  .alpha = 0.0
        }
        if isCancel {
            let userObj  = Constants.sharedInstance.USER!
            if let index = cell.currentIndex {
                if userObj.profileAnswers[index] == "" {
                    cell.txtViewResponse.text = "Add Response.."
                } else {
                    cell.txtViewResponse.text = userObj.profileAnswers[index]
                }
            }
        }
    }
    func setResponseCell(
        profileReference : ProfileVC,
        index            : Int
    ){
        let currentCell = profileReference.cvQuestions.cellForItem(
            at: IndexPath(
                row     : index,
                section : 0)
        ) as! ProfileQuestionCell
        currentCell.txtViewResponse.isEditable   = true
        currentCell.txtViewResponse.isSelectable = true
        currentCell.txtViewResponse.becomeFirstResponder()
        profileReference.setupResponseView()
        UIView.animate(withDuration: 0.5) {
            profileReference.viewResponse.alpha = 1.0
        }
        profileReference.btnSaveResponse.tag = index
        profileReference.btnCancel      .tag = index
        profileReference.btnSaveResponse.removeTarget(
            nil        ,
            action: nil,
            for   : .touchUpInside
        )
        profileReference.btnSaveResponse.addTarget(
            self                             ,
            action : #selector(saveTapped(_:)),
            for    : .touchUpInside)
        profileReference.btnCancel.addTarget(
            self                             ,
            action : #selector(cancelTapped(_:)),
            for    : .touchUpInside)
    }
}
/* MARK:- Api Methods */
extension ProfileQuestionDataController {
    func updateProfile(response : String, index : Int){
        let profileVC = Constants.sharedInstance.PROFILE_VC_REFERENCE!
        if !Reachability.isConnectedToNetwork() {
            profileVC.showToast(message: "No Internet Connection!")
            return
        }
        if let userObj = Constants.sharedInstance.USER {
            var updateParam : [String : Any] = [:]
            updateParam["userName"] = userObj.userName
            updateParam["age"]      = userObj.age
            var answersArray = userObj.profileAnswers
            answersArray[index] = response
            updateParam["profile_answers"] = answersArray
            profileVC.showSpinner(onView: profileVC.btnSaveResponse)
            NetworkManager.sharedInstance.updateProfile(param: updateParam) { (response) in
                profileVC.removeSpinner()
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
                            profileVC.cvQuestions.reloadData()
                        } else if response.response?.statusCode == 401 {
                            profileVC.showToast(message: "UnAuthorized : User Not Found")
                            profileVC.logoutUser()
                        } else {
                            profileVC.showToast(message: message)
                        }
                    }
                    catch {
                        profileVC.showToast(message: response.error?.localizedDescription ?? "Something went wrong")
                    }
                case .failure(_):
                    profileVC.showToast(message: "Something went wrong with Servers")
                }
            }
        }
    }
}


