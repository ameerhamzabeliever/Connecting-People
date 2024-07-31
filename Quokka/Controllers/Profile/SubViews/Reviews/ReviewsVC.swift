//
//  ReviewsVC.swift
//  Quokka
//
//  Created by Muhammad Zubair on 16/01/2021.
//  Copyright © 2021 Codes Binary. All rights reserved.
//

import UIKit
import SwiftyJSON
import SkeletonView
import XLPagerTabStrip

class ReviewsVC: UIViewController {
    /* MARK:- OUTLETS */
    /// Label
    @IBOutlet weak var lblReviewTitle : UILabel!
    /// TableView
    @IBOutlet weak var tvReviews : UITableView!
    /// Constraints
    @IBOutlet weak var constTopTableView : NSLayoutConstraint!
    /* MARK:- Properties */
    var currentPage : Int           = 1
    var totalPages  : Int           = 1
    var apiCalled   : Bool          = false /// Just to show empty message on table view after api is called
    var isLoading   : Bool          = false
    var allReviews  : [ReviewModel] = []
    var otherUserId : String        = ""
    /* MARK:- Life Cycle */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadData()
    }
}
/* MARK:- Methods */
extension ReviewsVC {
    func setupVC(){
        registerNibs()
        if otherUserId == "" {
            constTopTableView.constant = 10
            lblReviewTitle   .alpha    = 0.0
        } else {
            constTopTableView.constant = 50
            lblReviewTitle   .alpha    = 1.0
        }
    }
    func loadData(){
        currentPage = 1
        apiCalled   = false
        allReviews  = []
        tvReviews.setContentOffset(.zero, animated: false)
        tvReviews.reloadData()
        Helper.showTVSkeletonView(tableView: tvReviews)
        getAllReviews()
    }
    func registerNibs(){
        let reviewsNib = UINib(nibName: Constants.TVCELLS.REVIEW,bundle: nil)
        tvReviews.register(reviewsNib, forCellReuseIdentifier: Constants.TVCELLS.REVIEW)
    }
}
/* MARK:- Api Methods */
extension ReviewsVC {
    func getAllReviews(){
        if !Reachability.isConnectedToNetwork() {
            self.showToast(message: "No Internet Connection!")
            MAIN_DISPATCH.async {
                self.tvReviews.stopSkeletonAnimation()
            }
            return
        }
        apiCalled = true
        isLoading = true
        var param : [ String : Any] = ["page" : currentPage]
        if otherUserId != "" {
            param["userId"] = otherUserId
        }
        NetworkManager.sharedInstance.getAllReviews(param: param) { (response) in
            self.isLoading = false
            self.tvReviews.tableFooterView = nil
            MAIN_DISPATCH.async {
                self.tvReviews.hideSkeleton()
            }
            switch response.result {
            case .success(_):
                do {
                    let apiData = try JSON(data: response.data!)
                    Helper.debugLogs(any: apiData)
                    let dataObj = apiData["data"]
                    let message = dataObj["message"].stringValue
                    if response.response?.statusCode == 200 {
                        self.totalPages = dataObj["pages"].intValue
                        let reviewsJson = dataObj["reviews"]
                        let reviews = reviewsJson.arrayValue.map({ReviewModel(json: $0)})
                        self.allReviews.append(contentsOf: reviews)
                        self.tvReviews.reloadData()
                    } else if response.response?.statusCode == 401 {
                        self.showToast(message: "UnAuthorized : User Not Found")
                        self.logoutUser()
                    } else {
                        self.showToast(message: message)
                    }
                }
                catch {
                    self.showToast(message: response.error?.localizedDescription ?? "Something went wrong")
                }
            case .failure(_):
                self.showToast(message: "Something went wrong with Servers")
            }
        }
    }
}
/* MARK:- TableView Delegate and DataSource */
extension ReviewsVC : UITableViewDelegate, SkeletonTableViewDataSource {
    /// Skelton View Data Source
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return Constants.TVCELLS.REVIEW
    }
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    /// Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if apiCalled {
            if allReviews.count == 0 {
                tableView.setEmptyMessage("No Reviews Yet")
            } else {
                tableView.restoreEmptyMessage()
            }
        } else {
            tableView.restoreEmptyMessage()
        }
        return allReviews.count
    }
    /// Table View Delegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reviewCell = tableView.dequeueReusableCell(withIdentifier: Constants.TVCELLS.REVIEW) as! ReviewCell
        let row = indexPath.row
        reviewCell.setReviewCell(review: allReviews[row])
        return reviewCell
    }
    /// Scroll View Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if currentPage < totalPages {
            if position > (tvReviews.contentSize.height - 10 - scrollView.frame.size.height) {
                if isLoading {
                    // we are already fetching data
                    return
                }
                currentPage += 1
                tvReviews.tableFooterView = Helper.showLoadingFooter(tvReviews, .black)
                getAllReviews()
            }
        }
    }
}

/* MARK:- Pager Info Indicator */
extension ReviewsVC :  IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Reviews")
    }
}
