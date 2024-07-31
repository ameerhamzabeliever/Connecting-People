//
//  ColorCell.swift
//  Quokka
//
//  Created by Muhammad Zubair on 28/11/2020.
//  Copyright © 2020 Codes Binary. All rights reserved.
//

import UIKit

class ColorCell: UICollectionViewCell {

    /* MARK:- OUTLETS */
    /// Views
    @IBOutlet weak var viewOutter : UIView!
    @IBOutlet weak var viewInner  : UIView!
    /// ImageViews
    @IBOutlet weak var imgProfile : UIImageView!
    
    /* MARK:- LifeCycle */
    override func awakeFromNib() {
        super.awakeFromNib()
        layoutView()
    }

}
/* MARK:- Methods */
extension ColorCell {
    func layoutView(){
        minFontSize()
        MAIN_DISPATCH.async { [self] in
            viewOutter.layer.cornerRadius = viewOutter.bounds.height / 2
            viewInner .layer.cornerRadius = viewInner .bounds.height / 2
        }
    }
}
