//
//  LauchVC.swift
//  Quokka
//
//  Created by Muhammad Zubair on 05/12/2020.
//  Copyright © 2020 Codes Binary. All rights reserved.
//

import UIKit
import SwiftyJSON
import AVFoundation

class LauchVC: UIViewController {
    
    /* MARK:- Outlets */
    @IBOutlet weak var viewAnimatedVideo : UIView!
    
    /* MARK:- Properties */
    var player          : AVPlayer!
    var layer           : AVPlayerLayer = AVPlayerLayer()
    let modelName =  UIDevice.modelName
    /* MARK:- LifeCycle */
    override func viewDidLoad() {
        super.viewDidLoad()
        playAnimation()
        getGlobalSettings()
        getSuggestions()
        getFeedbackQuestions()
    }
    override func viewWillDisappear(_ animated: Bool) {
        player?.pause()
    }
}
/* MARK:- Methods */
extension LauchVC {
    func playAnimation(){
        initializeVideoPlayerWithVideo("animation")
    }
    func gotoLoginVC(){
        let loginVC  = LoginVC(
            nibName : Constants.VCNibs.LOGIN,
            bundle  : nil
        )
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    func gotoHomeVC(){
        let homeVC  = HomeVC(
            nibName : Constants.VCNibs.HOME,
            bundle  : nil
        )
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
    func gotoSetupVC(){
        let setupVC = SetupProfileVC(
            nibName : Constants.VCNibs.SETUP_PROFILE,
            bundle  : nil
        )
        self.navigationController?.pushViewController(setupVC, animated: true)
    }
    func initializeVideoPlayerWithVideo(_ resourse : String) {
        let videoString:String? = Bundle.main.path(
            forResource: resourse,
            ofType     : "mp4"
        )
        guard let unwrappedVideoPath = videoString else {return}
        
        let videoUrl      = URL(fileURLWithPath: unwrappedVideoPath)
        self.player       = AVPlayer(url: videoUrl)
        self.layer        = AVPlayerLayer(player: self.player)
        self.layer.frame  = CGRect(x: 0, y: 0, width: 375, height: 266.3)
        self.viewAnimatedVideo.layer.addSublayer(self.layer)
        self.player?.play()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.finishVideo),
            name    : NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object  : self.player.currentItem
        )
    }
}
/* MARK:- OBJ-C Methods */
extension LauchVC {
    @objc func finishVideo() {
        player?.pause()
        if let user = Constants.sharedInstance.USER {
            if user.userName == "" {
                gotoSetupVC()
            } else {
                gotoHomeVC()
            }
        } else {
            gotoLoginVC()
        }
    }
}
/* MARK:- Api Methods */
extension LauchVC {
    func getGlobalSettings(){
        if !Reachability.isConnectedToNetwork() {
            self.showToast(message: "No Internet Connection!")
            return
        }
        NetworkManager.sharedInstance.getGlobalSettings { (response) in
            switch response.result {
            case .success(_):
                do {
                    let apiData = try JSON(data: response.data!)
                    Helper.debugLogs(any: apiData)
                    let dataObj = apiData["data"]
                    if response.response?.statusCode == 200 {
                        let settingsJson = dataObj["settings"]
                        Constants.sharedInstance.CALL_LIMIT = settingsJson["limit"].intValue
                        Constants.sharedInstance.REST_DURATION = CGFloat(settingsJson["duration"].intValue)
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
    func getFeedbackQuestions(){
        if !Reachability.isConnectedToNetwork() {
            self.showToast(message: "No Internet Connection!")
            return
        }
        NetworkManager.sharedInstance.getFeedbackQuestions { (response) in
            switch response.result {
            case .success(_):
                do {
                    let apiData = try JSON(data: response.data!)
                    Helper.debugLogs(any: apiData)
                    let dataObj = apiData["data"]
                    if response.response?.statusCode == 200 {
                        let questionJSON = dataObj["feedbackQuestion"]
                        let questionsArray = questionJSON.arrayValue.map({$0["question"].stringValue})
                        Constants.sharedInstance.FEEDBACK_QUESTIONS = questionsArray
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
    func getSuggestions(){
        if !Reachability.isConnectedToNetwork() {
            self.showToast(message: "No Internet Connection!")
            return
        }
        NetworkManager.sharedInstance.getSuggestions { (response) in
            switch response.result {
            case .success(_):
                do {
                    let apiData = try JSON(data: response.data!)
                    Helper.debugLogs(any: apiData)
                    let dataObj = apiData["data"]
                    if response.response?.statusCode == 200 {
                        let suggestionsJSON = dataObj["convoStarter"]
                        let suggestionsArray = suggestionsJSON.arrayValue.map({$0["question"].stringValue})
                        Constants.sharedInstance.SUGGESTIONS = suggestionsArray
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
