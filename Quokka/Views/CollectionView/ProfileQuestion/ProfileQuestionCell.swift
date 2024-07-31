//
//  ProfileQuestionCell.swift
//  Quokka
//
//  Created by Muhammad Zubair on 26/11/2020.
//  Copyright © 2020 Codes Binary. All rights reserved.
//

import UIKit
import SwiftyJSON

class ProfileQuestionCell: UICollectionViewCell {
    
    /* MARK:- OUTLETS */
    /// Labels
    @IBOutlet weak var lblQuestion        : UILabel!
    /// TextViews
    @IBOutlet weak var txtViewResponse    : UITextView!
    /// Views
    @IBOutlet weak var viewMain           : UIView!
    /// Buttons
    @IBOutlet weak var btnCancel          : UIButton!
    @IBOutlet weak var btnSave            : UIButton!
    /// Constraints
    @IBOutlet weak var consLblQuestionTop : NSLayoutConstraint!
    /* MARK:- Properties */
    var currentIndex : Int?
    /* MARK:- LifeCycle */
    override func awakeFromNib() {
        super.awakeFromNib()
        layoutView()
    }
}

/* MARK:- Methods */
extension ProfileQuestionCell {
    func layoutView(){
        minFontSize()
        MAIN_DISPATCH.async { [self] in
            viewMain .layer.cornerRadius = viewMain .bounds.height / 6
        }
        if SCREEN_HEIGHT < 737 {
            consLblQuestionTop.constant = consLblQuestionTop.constant / 2
        }
    }
}


