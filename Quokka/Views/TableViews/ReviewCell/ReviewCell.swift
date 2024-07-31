//
//  ReviewCell.swift
//  Quokka
//
//  Created by Muhammad Zubair on 12/02/2021.
//  Copyright © 2021 Codes Binary. All rights reserved.
//

import UIKit

class ReviewCell: UITableViewCell {

    /* MARK:- Outlets */
    /// Views
    @IBOutlet weak var viewMain     : UIView!
    @IBOutlet weak var viewUserImg  : UIView!
    /// Labels
    @IBOutlet weak var lblReview    : UILabel!
    @IBOutlet weak var lblUserName  : UILabel!
    @IBOutlet weak var lblTimeStamp : UILabel!
    /// ImageViews
    @IBOutlet weak var imgUser      : UIImageView!
    
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
extension ReviewCell {
    func layoutView(){
        MAIN_DISPATCH.async {
            self.viewMain   .layer.cornerRadius = self.viewMain   .bounds.height / 8
            self.viewUserImg.layer.cornerRadius = self.viewUserImg.bounds.height / 2
        }
    }
    func setReviewCell ( review : ReviewModel) {
        if review.userObj.avatarUrl == "" {
            imgUser.image = UIImage(named: "Quokka-Placeholder")
        } else {
            Helper.setImage(
                imageView   : imgUser,
                imageUrl    : review.userObj.avatarUrl,
                placeholder : "Quokka-Placeholder"
            )
        }
        lblUserName .text = review.userObj.displayName
        lblReview   .text = review.reviewText
        lblTimeStamp.text = review.timeStamp
    }
}
