//
//  TwitterViewController.swift
//  Pager-Demo
//
//  Created by Yuto Akiba on 2019/07/14.
//  Copyright © 2019 Yuto Akiba. All rights reserved.
//

import UIKit
import Pager

final class TwitterViewController: UIViewController, Pager {

    @IBOutlet weak var containerView: VCSContainerView!
    @IBOutlet private weak var menuView: TwitterMenuView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuView.distribution = .equalSpacing
        menuView.alignment = .center
        menuView.selectedBarWidthMode = .automatic

        preparePager()
    }
    
    func viewControllers(for: PagerViewController) -> [UIViewController] {
        return [(UIColor.red, "Tweets"),
                (UIColor.blue, "Tweets & replies"),
                (UIColor.yellow, "Media"),
                (UIColor.orange, "Likes")]
            .map {
                let vc = storyboard!.instantiateViewController(withIdentifier: "ChildViewController")
                vc.view.backgroundColor = $0.0
                vc.title = $0.1
                return vc
        }
    }
    
    func menuProvider() -> MenuProvider? {
        return menuView
    }
    
    @IBAction func tappedCloseButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
