//
//  TrophiesVC.swift
//  Quokka
//
//  Created by Muhammad Zubair on 16/01/2021.
//  Copyright © 2021 Codes Binary. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class TrophiesVC: UIViewController {
    var profileReference : ProfileVC? = nil
    /* MARK:- Life Cycle */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.minFontSize()
    }
    
}
/* MARK:- Pager Info Indicator */
extension TrophiesVC :  IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Trophies")
    }
}
