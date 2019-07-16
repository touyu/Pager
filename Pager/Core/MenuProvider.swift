//
//  MenuProvider.swift
//  Pager
//
//  Created by Yuto Akiba on 2019/07/14.
//  Copyright © 2019 Yuto Akiba. All rights reserved.
//

import UIKit

public protocol MenuProviderDelegate: class {
    func didChangeIndex(menuBarView: MenuProvider, index: Int)
}

public extension MenuProviderDelegate {
    func didChangeIndex(menuBarView: MenuProvider, index: Int) {
        
    }
}

public protocol MenuProvider: class {
    var delegate: MenuProviderDelegate? { get set }
    var currentIndex: Int { get }
    func moveTo(fromIndex: Int, toIndex: Int, animated: Bool)
    func moveTo(fromIndex: Int, toIndex: Int, scrollPercentage: CGFloat, indexWasChanged: Bool)
    func sourceViewControllers(_ viewControllers: [UIViewController])
}
