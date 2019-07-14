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
        
        menuView.selectedViewInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
        menuView.titleFont = UIFont.systemFont(ofSize: 16, weight: .bold)
//        menuView.distribution = .equalSpacing
        
        preparePager()
    }

    func viewControllers(for: PagerViewController) -> [UIViewController] {
        let vc1 = storyboard!.instantiateViewController(withIdentifier: "ChildViewController")
        vc1.view.backgroundColor = .red
        vc1.title = "Child1"
        let vc2 = storyboard!.instantiateViewController(withIdentifier: "ChildViewController")
        vc2.view.backgroundColor = .blue
        vc2.title = "Child2"
        let vc3 = storyboard!.instantiateViewController(withIdentifier: "ChildViewController")
        vc3.view.backgroundColor = .yellow
        vc3.title = "Child3"
        return [vc1, vc2, vc3]
    }
    
    func menuProvider() -> MenuProvider? {
        return menuView
    }
}

