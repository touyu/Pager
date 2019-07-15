//
//  ViewController.swift
//  Pager-Demo
//
//  Created by Yuto Akiba on 2019/07/14.
//  Copyright © 2019 Yuto Akiba. All rights reserved.
//

import UIKit
import Pager

final class ViewController: UIViewController, Pager {
    @IBOutlet weak var containerView: VCSContainerView!
    @IBOutlet private weak var menuView: PinterestMenuView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuView.insets = UIEdgeInsets(top: 0,
                                       left: menuView.selectedViewInsets.left + 16,
                                       bottom: 0,
                                       right: menuView.selectedViewInsets.left + 16)
        menuView.distribution = .equalSpacing
        
        preparePager()
    }

    func viewControllers(for: PagerViewController) -> [UIViewController] {
        return [(UIColor.red, "RedVC"),
                (UIColor.blue, "BlueVC"),
                (UIColor.yellow, "YellowVC"),
                (UIColor.orange, "OrangeVC"),
                (UIColor.green, "GreenVC")]
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

