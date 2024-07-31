//
//  ConvoCell.swift
//  Quokka
//
//  Created by Muhammad Zubair on 27/11/2020.
//  Copyright © 2020 Codes Binary. All rights reserved.
//

import UIKit


class ConvoCell: UITableViewCell {
    /* MARK:- OUTLETS */
    /// Labels
    @IBOutlet weak var lblName            : UILabel!
    @IBOutlet weak var lblTimestamp       : UILabel!
    /// ImageViews
    @IBOutlet weak var imgProfile         : UIImageView!
    /// Views
    @IBOutlet weak var viewMain           : UIView!
    @IBOutlet weak var viewFriend         : UIView!
    @IBOutlet weak var viewAcceptFriend   : UIView!
    @IBOutlet weak var viewPendingRequest : UIView!
    @IBOutlet weak var viewAddFriend      : UIView!
    @IBOutlet weak var viewBlocked        : UIView!
    @IBOutlet weak var viewUnBlocked      : UIView!
    /// Buttons
    @IBOutlet weak var btnCall            : UIButton!
    @IBOutlet weak var btnShowProfile     : UIButton!
    @IBOutlet weak var btnAddFriend       : UIButton!
    @IBOutlet weak var btnAcceptRequest   : UIButton!
    @IBOutlet weak var btnCancelRequest   : UIButton!
    @IBOutlet weak var btnCancelPending   : UIButton!
    @IBOutlet weak var btnUnBlock         : UIButton!
    /// Outet Collections
    @IBOutlet var viewsRound             : [UIView]!
    /* MARK:- LifeCycle */
    override func awakeFromNib() {
        super.awakeFromNib()
        minFontSize()
        layoutView()
    }
    override func prepareForReuse() {
        layoutView()
    }
}
/* MARK:- Methods */
extension ConvoCell {
    func layoutView(){
        MAIN_DISPATCH.async { [self] in
            viewMain        .layer.cornerRadius = viewMain.bounds.height / 6
            for v in viewsRound {
                v.layer.cornerRadius = v.bounds.height / 2
            }
        }
    }
    func setupCellForCalls(_ currentCall : CallModel){
        lblTimestamp.text = currentCall.timeStamp
        lblName     .text = currentCall.toUser.displayName
        Helper.setImage(imageView: imgProfile, imageUrl: currentCall.toUser.avatarUrl, placeholder: "Quokka-Placeholder")
        switch currentCall.userStatus {
        case "Add":
            viewFriend        .alpha = 0.0
            viewAcceptFriend  .alpha = 0.0
            viewPendingRequest.alpha = 0.0
            viewAddFriend     .alpha = 1.0
            viewBlocked       .alpha = 0.0
            viewUnBlocked     .alpha = 0.0
            btnCall           .isUserInteractionEnabled = false
            btnAddFriend      .isUserInteractionEnabled = true
            btnAcceptRequest  .isUserInteractionEnabled = false
            btnCancelRequest  .isUserInteractionEnabled = false
            btnCancelPending  .isUserInteractionEnabled = false
        case "Friends" :
            viewFriend        .alpha = 1.0
            viewAcceptFriend  .alpha = 0.0
            viewPendingRequest.alpha = 0.0
            viewAddFriend     .alpha = 0.0
            viewBlocked       .alpha = 0.0
            viewUnBlocked     .alpha = 0.0
            btnUnBlock        .isUserInteractionEnabled = false
            btnCall           .isUserInteractionEnabled = true
            btnAddFriend      .isUserInteractionEnabled = false
            btnAcceptRequest  .isUserInteractionEnabled = false
            btnCancelRequest  .isUserInteractionEnabled = false
            btnCancelPending  .isUserInteractionEnabled = false
        case "Pending" :
            viewFriend        .alpha = 0.0
            viewAcceptFriend  .alpha = 0.0
            viewPendingRequest.alpha = 1.0
            viewAddFriend     .alpha = 0.0
            viewBlocked       .alpha = 0.0
            viewUnBlocked     .alpha = 0.0
            btnUnBlock        .isUserInteractionEnabled = false
            btnCall           .isUserInteractionEnabled = false
            btnAddFriend      .isUserInteractionEnabled = false
            btnAcceptRequest  .isUserInteractionEnabled = false
            btnCancelRequest  .isUserInteractionEnabled = false
            btnCancelPending  .isUserInteractionEnabled = true
        case "Accept" :
            viewFriend        .alpha = 0.0
            viewAcceptFriend  .alpha = 1.0
            viewPendingRequest.alpha = 0.0
            viewAddFriend     .alpha = 0.0
            viewBlocked       .alpha = 0.0
            viewUnBlocked     .alpha = 0.0
            btnUnBlock        .isUserInteractionEnabled = false
            btnCall           .isUserInteractionEnabled = false
            btnAddFriend      .isUserInteractionEnabled = false
            btnAcceptRequest  .isUserInteractionEnabled = true
            btnCancelRequest  .isUserInteractionEnabled = true
            btnCancelPending  .isUserInteractionEnabled = false
        case "UnBlock" :
            viewFriend        .alpha = 0.0
            viewAcceptFriend  .alpha = 0.0
            viewPendingRequest.alpha = 0.0
            viewAddFriend     .alpha = 0.0
            viewBlocked       .alpha = 0.0
            viewUnBlocked     .alpha = 1.0
            btnUnBlock        .isUserInteractionEnabled = true
            btnCall           .isUserInteractionEnabled = false
            btnAddFriend      .isUserInteractionEnabled = false
            btnAcceptRequest  .isUserInteractionEnabled = false
            btnCancelRequest  .isUserInteractionEnabled = false
            btnCancelPending  .isUserInteractionEnabled = false
        case "Blocked" :
            viewFriend        .alpha = 0.0
            viewAcceptFriend  .alpha = 0.0
            viewPendingRequest.alpha = 0.0
            viewAddFriend     .alpha = 0.0
            viewBlocked       .alpha = 1.0
            viewUnBlocked     .alpha = 0.0
            btnUnBlock        .isUserInteractionEnabled = false
            btnCall           .isUserInteractionEnabled = false
            btnAddFriend      .isUserInteractionEnabled = false
            btnAcceptRequest  .isUserInteractionEnabled = false
            btnCancelRequest  .isUserInteractionEnabled = false
            btnCancelPending  .isUserInteractionEnabled = false
        default:
            break
        }
    }
    
}
