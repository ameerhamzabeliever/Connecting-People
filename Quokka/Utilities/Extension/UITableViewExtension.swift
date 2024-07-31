//
//  UITableViewExtension.swift
//  Quokka
//
//  Created by Muhammad Zubair on 23/01/2021.
//  Copyright © 2021 Codes Binary. All rights reserved.
//

import UIKit

extension UITableView {
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(
            frame      : CGRect(
                x      : 0                     ,
                y      : 0                     ,
                width  : self.bounds.size.width,
                height : self.bounds.size.height)
        )
        messageLabel.text          = message
        messageLabel.textColor     = .black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font          = UIFont(name: "Apercu Pro Medium", size: 16.0)
        messageLabel.sizeToFit()
        self.backgroundView        = messageLabel
        self.separatorStyle        = .none
    }
    
    func restoreEmptyMessage() {
        self.backgroundView = nil
    }
    
    func setNoCallView(){
        let imageView = UIImageView(
            frame: CGRect(
                x      : 0,
                y      : 0,
                width  : self.bounds.size.width,
                height : self.bounds.size.width * 0.5772)
        )
        imageView.image = UIImage(named: "NoCalls")
        self.backgroundView = imageView
        self.separatorStyle = .none
    }
}
