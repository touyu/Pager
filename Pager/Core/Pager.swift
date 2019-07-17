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

public protocol PagerDelegate {
    func pager(_ pager: Pager, willChangeIndex index: Int)
    func pager(_ pager: Pager, didChangeIndex index: Int)
}

public extension PagerDelegate {
    func pager(_ pager: Pager, willChangeIndex index: Int) {
        
    }
    func pager(_ pager: Pager, didChangeIndex index: Int) {

    }
}

public protocol Pager: class, PagerDataSource, PagerDelegate {
    var containerView: VCSContainerView! { get }
    var viewControllers: [UIViewController] { get }
}

public typealias PagerViewController = Pager & UIViewController

public extension Pager {
    func menuProvider() -> MenuProvider? {
        return nil
    }
}

extension Pager where Self: UIViewController {
    public var viewControllers: [UIViewController] {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.childViewControllers) as? [UIViewController] ?? [] }
        set { objc_setAssociatedObject(self, &AssociatedKeys.childViewControllers, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    public var currentIndex: Int {
        return containerView.currentIndex
    }
    
    var containerViewDelegateManager: VCSContainerViewDelegateManager? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.containerViewDelegateManager) as? VCSContainerViewDelegateManager }
        set { objc_setAssociatedObject(self, &AssociatedKeys.containerViewDelegateManager, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    var menuViewDelegateManager: MenuViewDelegateManager? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.menuViewDelegateManager) as? MenuViewDelegateManager }
        set { objc_setAssociatedObject(self, &AssociatedKeys.menuViewDelegateManager, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
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

    public func moveTo(index: Int, animated: Bool) {
        menuProvider()?.moveTo(fromIndex: currentIndex, toIndex: index, animated: animated)
        containerView.moveTo(index: index, animated: animated)
    }
}

final class VCSContainerViewDelegateManager: NSObject, VCSContainerViewDelegate {
    weak var pager: PagerViewController!
    
    init(viewController: PagerViewController) {
        self.pager = viewController
    }
    
    func willMoveTo(toIndex: Int) {
        pager.pager(pager, willChangeIndex: toIndex)
    }
    
    func moveTo(fromIndex: Int, toIndex: Int, scrollPercentage: CGFloat, indexWasChanged: Bool) {
        pager.menuProvider()?.moveTo(fromIndex: fromIndex, toIndex: toIndex, scrollPercentage: scrollPercentage, indexWasChanged: indexWasChanged)
        if indexWasChanged {
            pager.pager(pager, didChangeIndex: toIndex)
        }
    }
}

final class MenuViewDelegateManager: NSObject, MenuProviderDelegate {
    weak var pager: PagerViewController!
    
    init(viewController: PagerViewController) {
        self.pager = viewController
    }
    
    func didChangeIndex(menuBarView: MenuProvider, index: Int) {
        pager.pager(pager, willChangeIndex: index)
        pager.containerView.moveTo(index: index, animated: true)
        pager.pager(pager, didChangeIndex: index)
    }
}

