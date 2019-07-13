//
//  Pager.swift
//  Pager
//
//  Created by Yuto Akiba on 2019/07/14.
//  Copyright © 2019 Yuto Akiba. All rights reserved.
//

import Foundation

private struct AssociatedKeys {
    static var containerViewDelegateManager = "containerViewDelegateManager"
    static var menuViewDelegateManager = "menuViewDelegateManager"
    static var childViewControllers = "childViewControllers"
}

public protocol PagerDataSource {
    func viewControllers(for: PagerViewController) -> [UIViewController]
    func menuProvider() -> MenuProvider?
}

public protocol Pager: class, PagerDataSource {
    var containerView: VCSContainerView! { get }
}

public typealias PagerViewController = Pager & UIViewController

public extension Pager {
    func menuProvider() -> MenuProvider? {
        return nil
    }
}

extension Pager where Self: UIViewController {
    var containerViewDelegateManager: VCSContainerViewDelegateManager? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.containerViewDelegateManager) as? VCSContainerViewDelegateManager }
        set { objc_setAssociatedObject(self, &AssociatedKeys.containerViewDelegateManager, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    var menuViewDelegateManager: MenuViewDelegateManager? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.menuViewDelegateManager) as? MenuViewDelegateManager }
        set { objc_setAssociatedObject(self, &AssociatedKeys.menuViewDelegateManager, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    var viewControllers: [UIViewController] {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.childViewControllers) as? [UIViewController] ?? [] }
        set { objc_setAssociatedObject(self, &AssociatedKeys.childViewControllers, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    public func preparePager() {
        containerViewDelegateManager = VCSContainerViewDelegateManager(viewController: self)
        menuViewDelegateManager = MenuViewDelegateManager(viewController: self)
        viewControllers = viewControllers(for: self)
        
        containerView.parentViewController = self
        containerView.setViewControllers(viewControllers)
        containerView.delegate = containerViewDelegateManager
        
        menuProvider()?.delegate = menuViewDelegateManager
        menuProvider()?.sourceViewControllers(viewControllers)
    }
}

final class VCSContainerViewDelegateManager: NSObject, VCSContainerViewDelegate {
    weak var pager: PagerViewController!
    
    init(viewController: PagerViewController) {
        self.pager = viewController
    }
    
    func moveTo(fromIndex: Int, toIndex: Int, scrollPercentage: CGFloat, indexWasChanged: Bool) {
        pager.menuProvider()?.moveTo(fromIndex: fromIndex, toIndex: toIndex, scrollPercentage: scrollPercentage, indexWasChanged: indexWasChanged)
    }
}

final class MenuViewDelegateManager: NSObject, MenuProviderDelegate {
    weak var pager: PagerViewController!
    
    init(viewController: PagerViewController) {
        self.pager = viewController
    }
    
    func didChangeIndex(menuBarView: MenuProvider, index: Int) {
        pager.containerView.moveTo(index: index, animated: true)
    }
}

