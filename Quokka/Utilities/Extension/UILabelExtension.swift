//
//  UILabelExtension.swift
//  Quokka
//
//  Created by Muhammad Zubair on 01/12/2020.
//  Copyright © 2020 Codes Binary. All rights reserved.
//

import UIKit

extension UILabel {
    
    func strokeText(strokeColor : UIColor,
                    strokeWidth : Float  )
    {
        let strokeTextAttributes = [
            NSAttributedString.Key.strokeColor : strokeColor,
            NSAttributedString.Key.foregroundColor : self.textColor!,
            NSAttributedString.Key.strokeWidth : strokeWidth,
            NSAttributedString.Key.font : self.font!
        ] as [NSAttributedString.Key : Any]

        self.attributedText = NSMutableAttributedString(string: self.text!, attributes: strokeTextAttributes)
    }
}
