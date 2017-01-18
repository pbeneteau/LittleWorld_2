//
//  MenuVC.swift
//  LittleWorld
//
//  Created by antoine beneteau on 2017-01-16.
//  Copyright © 2017 Paul Bénéteau. All rights reserved.
//

import Foundation
import UIKit

class MenuVC: EZSwipeController {
    var _storyboard = UIStoryboard(name: "Main", bundle: nil)
    var profileVC: ProfileVC!
    var locatorVC: HomeViewController!
    var chatVC: ChatVC!
    
    override func setupView() {
        datasource = self
        navigationBarShouldNotExist = true
    }
}

extension MenuVC: EZSwipeControllerDataSource {
    func viewControllerData() -> [UIViewController] {
        
        profileVC = storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        locatorVC = storyboard?.instantiateViewController(withIdentifier: "LocatorVC") as! HomeViewController
        chatVC = storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        
        return [profileVC,locatorVC,chatVC]
    }
    
    func indexOfStartingPage() -> Int {
        return 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        for someview in self.pageViewController.view.subviews {
            if someview is UIScrollView {
                let scrollview = someview as! UIScrollView
                scrollview.delegate = self
            }
        }
    }
    
}

extension MenuVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.currentVCIndex == 0 && (scrollView.contentOffset.x < scrollView.bounds.size.width) {
            scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
        } else if self.currentVCIndex == self.stackVC.count - 1 && (scrollView.contentOffset.x > scrollView.bounds.size.width) {
            scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
        }
        
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if self.currentVCIndex == 0 && (scrollView.contentOffset.x < scrollView.bounds.size.width) {
            scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
        } else if self.currentVCIndex == self.stackVC.count - 1 && (scrollView.contentOffset.x > scrollView.bounds.size.width) {
            scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
        }
        profileVC.mainUser = locatorVC.mainUser
    }
}

