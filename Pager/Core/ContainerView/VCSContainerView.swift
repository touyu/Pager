//
//  VCSContainerView.swift
//  imo_ios
//
//  Created by Yuto Akiba on 2019/07/13.
//  Copyright © 2019 Yuto Akiba. All rights reserved.
//

import UIKit

protocol VCSContainerViewDelegate: class {
    func moveTo(fromIndex: Int, toIndex: Int, scrollPercentage: CGFloat, indexWasChanged: Bool)
}

final public class VCSContainerView: UIView, NibOwnerLoadable {
    @IBOutlet private weak var collectionView: UICollectionView!
    
    weak var parentViewController: UIViewController!
    weak var delegate: VCSContainerViewDelegate?
    var viewControllers: [UIViewController] = []
    
    var currentIndex: Int = 0
    
    enum SwipeDirection {
        case left
        case right
        case none
    }
    
    private var lastContentOffsetX: CGFloat = 0
    
    private var swipeDirection: SwipeDirection {
        if collectionView.contentOffset.x > lastContentOffsetX {
            return .left
        } else if collectionView.contentOffset.x < lastContentOffsetX {
            return .right
        }
        return .none
    }
    
    private var scrollPercentage: CGFloat {
        let value = fmod(collectionView.contentOffset.x, collectionView.bounds.width) / collectionView.bounds.width
        if swipeDirection == .right {
            return 1 - value
        }
        return value
    }
    
    private var programmaticallyScrolling = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        loadNib()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
        }
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(ContainerCollectionViewCell.self)
    }
    
    func setViewControllers(_ viewControllers: [UIViewController]) {
        self.viewControllers = viewControllers
    }
    
    func moveTo(index: Int, animated: Bool) {
        if currentIndex == index {
            return
        }
        programmaticallyScrolling = true
        collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .left, animated: animated)
    }
}

extension VCSContainerView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewControllers.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(type: ContainerCollectionViewCell.self, for: indexPath)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let childVC = viewControllers[indexPath.item]
        childVC.didMove(toParent: parentViewController)
        childVC.view.frame = cell.contentView.bounds
        cell.contentView.addSubview(childVC.view)
        parentViewController.addChild(childVC)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let childVC = viewControllers[indexPath.item]
        childVC.view.removeFromSuperview()
        childVC.willMove(toParent: nil)
        childVC.removeFromParent()
    }
}

extension VCSContainerView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let oldCurrentIndex = currentIndex
        let newCurrentIndex = pageFor(contentOffset: scrollView.contentOffset.x)
        currentIndex = newCurrentIndex
        if !programmaticallyScrolling {
            let changeCurrentIndex = newCurrentIndex != oldCurrentIndex
            let (fromIndex, toIndex, scrollPercentage) = progressiveIndicatorData(newCurrentIndex)
            delegate?.moveTo(fromIndex: fromIndex, toIndex: toIndex, scrollPercentage: scrollPercentage, indexWasChanged: changeCurrentIndex)
        }
        lastContentOffsetX = scrollView.contentOffset.x
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if programmaticallyScrolling {
            programmaticallyScrolling = false
        }
    }
    
    func pageFor(contentOffset: CGFloat) -> Int {
        let number = collectionView.numberOfItems(inSection: 0)
        return Int(round(contentOffset / collectionView.contentSize.width * CGFloat(number)))
    }
    
    private func progressiveIndicatorData(_ virtualPage: Int) -> (Int, Int, CGFloat) {
        let count = viewControllers.count
        var fromIndex = currentIndex
        var toIndex = currentIndex
        let direction = swipeDirection
        var percentage = scrollPercentage
        
        if direction == .left {
            if virtualPage > count - 1 {
                fromIndex = count - 1
                toIndex = count
            } else {
                if self.scrollPercentage >= 0.5 {
                    fromIndex = max(toIndex - 1, 0)
                } else {
                    toIndex = fromIndex + 1
                }
                
                if toIndex == count {
                    percentage += 1
                    fromIndex -= 1
                    toIndex -= 1
                }
            }
        } else if direction == .right {
            if virtualPage < 0 {
                fromIndex = 0
                toIndex = -1
            } else {
                if self.scrollPercentage > 0.5 {
                    fromIndex = min(toIndex + 1, count)
                } else {
                    toIndex = fromIndex - 1
                }
                
                if fromIndex == count {
                    percentage -= 1
                    fromIndex -= 1
                    toIndex -= 1
                }
            }
        }
        
        return (fromIndex, toIndex, percentage)
    }
}
