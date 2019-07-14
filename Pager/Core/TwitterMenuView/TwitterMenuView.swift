//
//  TwitterMenuView.swift
//  Pager
//
//  Created by Yuto Akiba on 2019/07/14.
//  Copyright © 2019 Yuto Akiba. All rights reserved.
//

import UIKit

final public class TwitterMenuView: UIView, NibOwnerLoadable, MenuProvider {
    public enum Distribution {
        case fillEqually
        case equalSpacing
    }
    
    public enum SelectedBarWidthMode {
        case automatic
        case fillEqually
        case fixed(width: CGFloat)
    }
    
    public enum Alignment {
        case left
        case center
    }
    
    public var distribution: Distribution = .fillEqually
    public var alignment: Alignment = .left
    public var insets: UIEdgeInsets = .zero
    public var itemSpacing: CGFloat = 32
    public var titleFont: UIFont = UIFont.boldSystemFont(ofSize: 14)
    public var selectedTextColor = UIColor(hex: 0x1DA1F2)
    public var deselectedTextColor = UIColor.darkGray
    public var selectedBarColor = UIColor(hex: 0x1DA1F2)
    public var selectedBarHeight: CGFloat = 2
    public var selectedBarInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    public var selectedBarWidthMode: SelectedBarWidthMode = .automatic
    public var shouldFillAvailiableWidth = false
    
    public weak var delegate: MenuProviderDelegate?
    private(set) public var currentIndex: Int = 0
    
    @IBOutlet private weak var collectionView: UICollectionView!
    private var titles: [String] = []
    private var selectedBar = UIView()
    private var lastContentOffsetX: CGFloat = 0
    
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
        
        // Scroll diff
        let totalWidth = collectionView.contentSize.width
        let diff = totalWidth - collectionView.bounds.width

        if diff > 0 {
            let fromValue = diff / CGFloat(titles.count-1)  * CGFloat(fromIndex)
            let toValue = diff / CGFloat(titles.count-1)  * CGFloat(toIndex)
            let value = (toValue - fromValue) * scrollPercentage + fromValue
            var offset = collectionView.contentOffset
            offset.x = value
            collectionView.setContentOffset(offset, animated: false)
        }
        
        guard let fromAttributes = getAttributes(index: fromIndex),
            let toAttributes = getAttributes(index: toIndex) else { return }
        let fromPoint = collectionView.convert(fromAttributes.center, to: self)
        let toPoint = collectionView.convert(toAttributes.center, to: self)
        let pointX = (toPoint.x - fromPoint.x) * scrollPercentage + fromPoint.x
        selectedBar.center.x = pointX
    
        switch selectedBarWidthMode {
        case .automatic:
            switch alignment {
            case .left:
                let inset = selectedBarInsets.left + selectedBarInsets.right
                let fromWidth = titleLabelSize(string: titles[fromIndex]).width + inset
                let toWidth = titleLabelSize(string: titles[toIndex]).width  + inset
                let width = (toWidth - fromWidth) * scrollPercentage + fromWidth
                selectedBar.frame.size.width = width
            case .center:
                let inset = itemSpacing
                let fromWidth = titleLabelSize(string: titles[fromIndex]).width + inset
                let toWidth = titleLabelSize(string: titles[toIndex]).width  + inset
                let width = (toWidth - fromWidth) * scrollPercentage + fromWidth
                selectedBar.frame.size.width = width
            }
        case .fillEqually:
            let count = collectionView.numberOfItems(inSection: 0)
            let width = collectionView.bounds.width / CGFloat(count)
            selectedBar.frame.size.width = width
        case .fixed(width: let width):
            selectedBar.frame.size.width = width
        }
    }
    
    public func sourceViewControllers(_ viewControllers: [UIViewController]) {
        titles = viewControllers
            .compactMap { $0 as? MenuTitleProvider }
            .map { $0.menuTitle }
        
        switch alignment {
        case .left:
            break
        case .center:
            itemSpacing = 0
            insets = .zero
            
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
            let spacing = (collectionView.bounds.width - collectionView.contentSize.width) / CGFloat(titles.count)
            itemSpacing = spacing
            insets = UIEdgeInsets(top: 0, left: spacing / 2, bottom: 0, right: spacing / 2)
        }
        
        updateSelectedBar()
    }
    
    private func moveTo(fromIndex: Int, toIndex: Int, animated: Bool) {
        currentIndex = toIndex
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        
        // Scroll diff
        let totalWidth = collectionView.contentSize.width
        let diff = totalWidth - collectionView.bounds.width

        if diff > 0 {
            let value = diff / CGFloat(titles.count-1)  * CGFloat(toIndex)
            var offset = collectionView.contentOffset
            offset.x = value
            collectionView.setContentOffset(offset, animated: true)
        }
        
        guard let fromAttributes = getAttributes(index: fromIndex),
            let toAttributes = getAttributes(index: toIndex) else { return }
        let fromPoint = collectionView.convert(fromAttributes.center, to: self)
        let toPoint = collectionView.convert(toAttributes.center, to: self)
        selectedBar.center.x = fromPoint.x
        
        switch selectedBarWidthMode {
        case .automatic:
            switch alignment {
            case .left:
                let inset = selectedBarInsets.left + selectedBarInsets.right
                let fromWidth = titleLabelSize(string: titles[fromIndex]).width + inset
                let toWidth = titleLabelSize(string: titles[toIndex]).width  + inset
                selectedBar.frame.size.width = fromWidth
                updateSelectedBarWidth(toWidth, centerX: toPoint.x, animated: animated)
            case .center:
                let inset = itemSpacing
                let fromWidth = titleLabelSize(string: titles[fromIndex]).width + inset
                let toWidth = titleLabelSize(string: titles[toIndex]).width  + inset
                selectedBar.frame.size.width = fromWidth
                updateSelectedBarWidth(toWidth, centerX: toPoint.x, animated: animated)
            }
        case .fillEqually:
            let count = collectionView.numberOfItems(inSection: 0)
            let width = collectionView.bounds.width / CGFloat(count)
            selectedBar.frame.size.width = width
        case .fixed(width: let width):
            selectedBar.frame.size.width = width
            updateSelectedBarWidth(width, centerX: toPoint.x, animated: animated)
        }
    }
    
    private func updateSelectedBarWidth(_ width: CGFloat, centerX: CGFloat, animated: Bool) {
        if !animated {
            selectedBar.frame.size.width = width
            selectedBar.center.x = centerX
            return
        }
        
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.selectedBar.frame.size.width = width
            self?.selectedBar.center.x = centerX
        }
    }
    
    private func updateSelectedBar() {
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        
        switch selectedBarWidthMode {
        case .automatic:
            switch alignment {
            case .left:
                let inset = selectedBarInsets.left + selectedBarInsets.right
                let width = titleLabelSize(string: titles[currentIndex]).width + inset
                selectedBar.frame.size = CGSize(width: width, height: selectedBarHeight)
            case .center:
                let inset = itemSpacing
                let width = titleLabelSize(string: titles[currentIndex]).width + inset
                selectedBar.frame.size = CGSize(width: width, height: selectedBarHeight)
            }
        case .fillEqually:
            let count = collectionView.numberOfItems(inSection: 0)
            let width = collectionView.bounds.width / CGFloat(count)
            selectedBar.frame.size = CGSize(width: width, height: selectedBarHeight)
        case .fixed(width: let width):
            selectedBar.frame.size = CGSize(width: width, height: selectedBarHeight)
        }
        
        guard let attributes = getAttributes(index: currentIndex) else { return }
        let point = collectionView.convert(attributes.center, to: collectionView)
        selectedBar.center.x = point.x
        selectedBar.frame.origin.y = collectionView.bounds.height - selectedBar.bounds.height
    }
    
    private func getAttributes(index: Int) -> UICollectionViewLayoutAttributes? {
        return collectionView.layoutAttributesForItem(at: IndexPath(item: index, section: 0))
    }
    
    private func titleLabelSize(string: String) -> CGSize {
        return NSString(string: string)
            .size(withAttributes: [NSAttributedString.Key.font: titleFont])
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
        cell.titleLabel.font = titleFont
        return cell
    }
}

extension TwitterMenuView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch distribution {
        case .fillEqually:
            let count = collectionView.numberOfItems(inSection: 0)
            let totalWidth = collectionView.bounds.width - insets.left - insets.right
            return CGSize(width: totalWidth / CGFloat(count), height: collectionView.bounds.height)
        case .equalSpacing:
            let title = titles[indexPath.item]
            let size = titleLabelSize(string: title)
            return CGSize(width: size.width, height: collectionView.bounds.height)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch distribution {
        case .fillEqually:
            return 0
        case .equalSpacing:
            return itemSpacing
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        switch distribution {
        case .fillEqually:
            return 0
        case .equalSpacing:
            return itemSpacing
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return insets
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let fromIndex = currentIndex
        currentIndex = indexPath.item
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        
        moveTo(fromIndex: fromIndex, toIndex: currentIndex, animated: true)
        
        delegate?.didChangeIndex(menuBarView: self, index: indexPath.item)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        selectedBar.frame.origin.x -= scrollView.contentOffset.x - lastContentOffsetX
        lastContentOffsetX = scrollView.contentOffset.x
    }
}
