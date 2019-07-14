//
//  TwitterMenuView.swift
//  Pager
//
//  Created by Yuto Akiba on 2019/07/14.
//  Copyright © 2019 Yuto Akiba. All rights reserved.
//

import UIKit

final public class TwitterMenuView: UIView, NibOwnerLoadable, MenuProvider {
    public var selectedTextColor = UIColor.blue
    public var deselectedTextColor = UIColor.darkGray
    public var selectedBarColor = UIColor.blue
    public var selectedBarHeight: CGFloat = 2
    
    public weak var delegate: MenuProviderDelegate?
    private(set) public var currentIndex: Int = 0
    
    @IBOutlet private weak var collectionView: UICollectionView!
    private var titles: [String] = []
    private var selectedBar = UIView()
    
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
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(TwitterMenuViewCell.self)
        
        addSubview(selectedBar)
        selectedBar.backgroundColor = selectedBarColor
    }
    
    public func moveTo(fromIndex: Int, toIndex: Int, scrollPercentage: CGFloat, indexWasChanged: Bool) {
        if indexWasChanged {
            currentIndex = toIndex
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
        }
        
//        // Scroll
//        let totalWidth = collectionView.contentSize.width
//        let diff = totalWidth - collectionView.bounds.width
//
//        if diff > 0 {
//            let fromValue = diff / CGFloat(titles.count-1)  * CGFloat(fromIndex)
//            let toValue = diff / CGFloat(titles.count-1)  * CGFloat(toIndex)
//            let value = (toValue - fromValue) * scrollPercentage + fromValue
//            var offset = collectionView.contentOffset
//            offset.x = value
//            collectionView.setContentOffset(offset, animated: false)
//        }
        
        guard let fromAttributes = getAttributes(index: fromIndex),
            let toAttributes = getAttributes(index: toIndex) else { return }
        let fromPoint = collectionView.convert(fromAttributes.center, to: self)
        let toPoint = collectionView.convert(toAttributes.center, to: self)
        let pointX = (toPoint.x - fromPoint.x) * scrollPercentage + fromPoint.x
        selectedBar.center.x = pointX
        
//        let inset = selectedViewInsets.left + selectedViewInsets.right
//        let fromWidth = titleLabelSize(string: titles[fromIndex]).width + inset
//        let toWidth = titleLabelSize(string: titles[toIndex]).width  + inset
//        let width = (toWidth - fromWidth) * scrollPercentage + fromWidth
//        selectedBar.frame.size.width = width
    }
    
    public func sourceViewControllers(_ viewControllers: [UIViewController]) {
        titles = viewControllers
            .compactMap { $0 as? MenuTitleProvider }
            .map { $0.menuTitle }
        
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        
        updateSelectedBar()
    }
    
    private func moveTo(fromIndex: Int, toIndex: Int, animated: Bool) {
        currentIndex = toIndex
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        
//        // Scroll
//        let totalWidth = collectionView.contentSize.width
//        let diff = totalWidth - collectionView.bounds.width
//
//        if diff > 0 {
//            let value = diff / CGFloat(titles.count-1)  * CGFloat(toIndex)
//            var offset = collectionView.contentOffset
//            offset.x = value
//            collectionView.setContentOffset(offset, animated: true)
//        }
        
        guard let fromAttributes = getAttributes(index: fromIndex),
            let toAttributes = getAttributes(index: toIndex) else { return }
        let fromPoint = collectionView.convert(fromAttributes.center, to: self)
        let toPoint = collectionView.convert(toAttributes.center, to: self)
        selectedBar.center.x = fromPoint.x
        
//        let inset = selectedViewInsets.left + selectedViewInsets.right
//        let fromWidth = titleLabelSize(string: titles[fromIndex]).width + inset
//        let toWidth = titleLabelSize(string: titles[toIndex]).width  + inset
//        selectedView.frame.size.width = fromWidth
        
        
        if !animated {
//            selectedBar.frame.size.width = toWidth
            selectedBar.center.x = toPoint.x
            return
        }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
//            self?.selectedBar.frame.size.width = toWidth
            self?.selectedBar.center.x = toPoint.x
        }
    }
    
    private func updateSelectedBar() {
        guard let attributes = getAttributes(index: currentIndex) else { return }
        selectedBar.frame.size = CGSize(width: attributes.bounds.width, height: selectedBarHeight)
        selectedBar.frame.origin.y = collectionView.bounds.height - selectedBar.bounds.height
    }
    
    private func getAttributes(index: Int) -> UICollectionViewLayoutAttributes? {
        return collectionView.layoutAttributesForItem(at: IndexPath(item: index, section: 0))
    }
}

extension TwitterMenuView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(type: TwitterMenuViewCell.self, for: indexPath)
        cell.titleLabel.textColor = currentIndex == indexPath.item ? selectedTextColor : deselectedTextColor
        cell.titleLabel.text = titles[indexPath.item]
        return cell
    }
}

extension TwitterMenuView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let count = collectionView.numberOfItems(inSection: 0)
        return CGSize(width: collectionView.bounds.width / CGFloat(count), height: collectionView.bounds.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let fromIndex = currentIndex
        currentIndex = indexPath.item
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        
        moveTo(fromIndex: fromIndex, toIndex: currentIndex, animated: true)
        
        delegate?.didChangeIndex(menuBarView: self, index: indexPath.item)
    }
}
