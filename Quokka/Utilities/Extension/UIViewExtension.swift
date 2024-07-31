//
//  UIViewExtension.swift
//  Quokka
//
//  Created by Muhammad Zubair on 26/11/2020.
//  Copyright © 2020 Codes Binary. All rights reserved.
//

import UIKit

extension UIView {
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    func dismissKeyboard(){
        let selector   = #selector(didTapOnView(_:))
        let tapGesture = UITapGestureRecognizer(target: self, action: selector)
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func didTapOnView(_ sender: UITapGestureRecognizer){
        self.endEditing(true)
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        
        get{
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    var parentVC: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if parentResponder is UIViewController {
                return parentResponder as! UIViewController?
            }
        }
        return nil
    }
    private func getSubviewsOf<T : UIView>(view:UIView) -> [T] {
        var subviews = [T]()
        for subview in view.subviews {
            subviews += getSubviewsOf(view: subview) as [T]
            if let subview = subview as? T {
                subviews.append(subview)
            }
        }
        return subviews
    }
    
    func minFontSize() {
        if SCREEN_HEIGHT < 668 {
            let allButtons   :[UIButton]    = getSubviewsOf(view: self)
            let allLabels    :[UILabel]     = getSubviewsOf(view: self)
            let allTextFields:[UITextField] = getSubviewsOf(view: self)
            let allTextViews :[UITextView]  = getSubviewsOf(view: self)
            
            for label in allLabels {
                let font = label.font
                let size = font!.pointSize - 2.0
                label.font = font?.withSize(size)
            }
            for button in allButtons {
                let font = button.titleLabel?.font
                let size = font!.pointSize - 2.0
                button.titleLabel?.font = font?.withSize(size)
            }
            for textField in allTextFields {
                let font = textField.font
                let size = font!.pointSize - 2.0
                textField.font = font?.withSize(size)
            }
            for textView in allTextViews {
                let font = textView.font
                let size = font!.pointSize - 2.0
                textView.font = font?.withSize(size)
            }
        } else if SCREEN_HEIGHT < 737 {
            let allButtons   :[UIButton]    = getSubviewsOf(view: self)
            let allLabels    :[UILabel]     = getSubviewsOf(view: self)
            let allTextFields:[UITextField] = getSubviewsOf(view: self)
            let allTextViews :[UITextView]  = getSubviewsOf(view: self)
            
            for label in allLabels {
                let font = label.font
                let size = font!.pointSize - 1.0
                label.font = font?.withSize(size)
            }
            for button in allButtons {
                let font = button.titleLabel?.font
                let size = font!.pointSize - 1.0
                button.titleLabel?.font = font?.withSize(size)
            }
            for textField in allTextFields {
                let font = textField.font
                let size = font!.pointSize - 1.0
                textField.font = font?.withSize(size)
            }
            for textView in allTextViews {
                let font = textView.font
                let size = font!.pointSize - 1.0
                textView.font = font?.withSize(size)
            }
        }
    }
}

@IBDesignable
public class Gradient: UIView {
    @IBInspectable var startColor:   UIColor = .black { didSet { updateColors() }}
    @IBInspectable var endColor:     UIColor = .white { didSet { updateColors() }}
    @IBInspectable var startLocation: Double =   0.05 { didSet { updateLocations() }}
    @IBInspectable var endLocation:   Double =   0.95 { didSet { updateLocations() }}
    @IBInspectable var horizontalMode:  Bool =  false { didSet { updatePoints() }}
    @IBInspectable var diagonalMode:    Bool =  false { didSet { updatePoints() }}

    override public class var layerClass: AnyClass { CAGradientLayer.self }

    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? .init(x: 1, y: 0) : .init(x: 0, y: 0.5)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 0, y: 1) : .init(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? .init(x: 0, y: 0) : .init(x: 0.5, y: 0)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 1, y: 1) : .init(x: 0.5, y: 1)
        }
    }
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    func updateColors() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updatePoints()
        updateLocations()
        updateColors()
    }

}
