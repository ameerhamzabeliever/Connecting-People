//
//  ColorVC.swift
//  Quokka
//
//  Created by Muhammad Zubair on 28/11/2020.
//  Copyright © 2020 Codes Binary. All rights reserved.
//

import UIKit
import SwiftyJSON

class ColorVC: UIViewController {
    
    /* MARK:- OUTLETS */
    /// CollectionViews
    @IBOutlet weak var cvColors : UICollectionView!
    /// Views
    @IBOutlet weak var viewColorAvailable : UIView!
    /// Labels
    @IBOutlet weak var lblAvailableText   : UILabel!
    
    
    /* MARK:- PROPERTIES */
    var userAvatar        : UIImage   = UIImage()
    var selectedIndex     : Int       = -1
    let cellSelectedColor : UIColor   = #colorLiteral(red: 0.06666666667, green: 0.1529411765, blue: 0.0431372549, alpha: 1)
    var selectedColorName : String    = ""
    
    /* MARK:- CLOSURES */
    var didLoadData       : ((_ selectedColorName : String) -> Void)?
    
    /* MARK:- LifeCycle */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if selectedColorName != "" {
            self.didLoadData?(self.selectedColorName)
        }
    }
    
}
/* MARK:- Methods */
extension ColorVC {
    func setupVC(){
        registerNib()
        setAvailableView()
    }
    func registerNib(){
        let ColorNib = UINib(nibName: Constants.CVCELLS.COLOR, bundle: nil)
        cvColors.register(ColorNib, forCellWithReuseIdentifier: Constants.CVCELLS.COLOR)
    }
    func setAvailableView(){
        if Constants.sharedInstance.TOTAL_CALLS < 2 {
            self.lblAvailableText  .text  = "\(2 - Constants.sharedInstance.TOTAL_CALLS) more conversations to go and you can unlock colors"
            self.viewColorAvailable.alpha = 1.0
        } else {
            self.viewColorAvailable.alpha = 0.0
        }
    }
}
/* MARK:- Collection DataSource & Delegates */
extension ColorVC :
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PROFILE_COLORS.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let colorCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CVCELLS.COLOR, for: indexPath) as! ColorCell
        let row = indexPath.row
        colorCell.viewOutter.backgroundColor = PROFILE_COLORS[row].color
        colorCell.viewInner .backgroundColor = PROFILE_COLORS[row].color
        colorCell.imgProfile.image           = nil
        if let userObj = Constants.sharedInstance.USER {
            if !PROFILE_COLORS_DICT.keys.contains(userObj.color) || userObj.color == ""  {
                if PROFILE_COLORS[row].name == Constants.sharedInstance.selectedColor {
                    colorCell.viewOutter.backgroundColor = cellSelectedColor
                    colorCell.imgProfile.image           = userAvatar
                }
            } else {
                if PROFILE_COLORS[row].name == Constants.sharedInstance.USER?.color {
                    colorCell.viewOutter.backgroundColor = cellSelectedColor
                    colorCell.imgProfile.image           = userAvatar
                }
            }
        }
        
        return colorCell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let colorCell = collectionView.cellForItem(at: indexPath) as! ColorCell
        let row  = indexPath.row
        for i in 0...PROFILE_COLORS.count - 1 {
            let index = IndexPath(row: i, section: 0)
            let cell  = collectionView.cellForItem(at: index) as! ColorCell
            cell.viewOutter.backgroundColor = PROFILE_COLORS[index.row].color
            cell.imgProfile.image           = nil
        }
        colorCell.viewOutter.backgroundColor = cellSelectedColor
        colorCell.imgProfile.image           = userAvatar
        selectedColorName                    = PROFILE_COLORS[row].name
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (cvColors.bounds.width * 0.7953) / 4
        return CGSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let spacing = ( cvColors.bounds.width * 0.2047 ) / 3
        return spacing
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let spacing = ( cvColors.bounds.width * 0.2047 ) / 3
        return spacing
    }
}

