//
//  ConvoCell.swift
//  Quokka
//
//  Created by Muhammad Zubair on 27/11/2020.
//  Copyright © 2020 Codes Binary. All rights reserved.
//

import UIKit


class FriendCell: UITableViewCell {
    /* MARK:- OUTLETS */
    /// Labels
    @IBOutlet weak var lblNameForFriends  : UILabel!
    /// ImageViews
    @IBOutlet weak var imgProfile         : UIImageView!
    /// Views
    @IBOutlet weak var viewMain           : UIView!
    @IBOutlet weak var viewFriend         : UIView!
    @IBOutlet weak var viewAcceptFriend   : UIView!
    /// Buttons
    @IBOutlet weak var btnShowProfile     : UIButton!
    @IBOutlet weak var btnCall            : UIButton!
    @IBOutlet weak var btnAcceptRequest   : UIButton!
    @IBOutlet weak var btnCancelRequest   : UIButton!
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
extension FriendCell {
    func layoutView(){
        MAIN_DISPATCH.async { [self] in
            viewMain        .layer.cornerRadius = viewMain.bounds.height / 6
            for v in viewsRound {
                v.layer.cornerRadius = v.bounds.height / 2
            }
        }
    }
    func setupCellForFriends(_ user : UserModel){
        lblNameForFriends.text = user.displayName
        Helper.setImage(imageView: imgProfile, imageUrl: user.avatarUrl, placeholder: "Quokka-Placeholder")
        viewFriend        .alpha = 1.0
        viewAcceptFriend  .alpha = 0.0
        btnCall           .isUserInteractionEnabled = true
        btnAcceptRequest  .isUserInteractionEnabled = false
        btnCancelRequest  .isUserInteractionEnabled = false
    }
    func setupCellForRequests(_ user : UserModel){
        lblNameForFriends.text = user.displayName
        Helper.setImage(imageView: imgProfile, imageUrl: user.avatarUrl, placeholder: "Quokka-Placeholder")
        viewFriend        .alpha = 0.0
        viewAcceptFriend  .alpha = 1.0
        btnCall           .isUserInteractionEnabled = false
        btnAcceptRequest  .isUserInteractionEnabled = true
        btnCancelRequest  .isUserInteractionEnabled = true
    }
    
}
