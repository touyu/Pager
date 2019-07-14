//
//  PinterestMenuView.swift
//  imo_ios
//
//  Created by Yuto Akiba on 2019/07/13.
//  Copyright © 2019 Yuto Akiba. All rights reserved.
//

import UIKit

public protocol MenuTitleProvider: class {
    var menuTitle: String { get }
}

final public class PinterestMenuView: UIView, NibOwnerLoadable, MenuProvider {
    public enum Distribution {
        case fillEqually
        case equalSpacing
    }
    
    public weak var delegate: MenuProviderDelegate?
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    public var distribution: Distribution = .fillEqually
    public var itemSpacing: CGFloat = 32
    public var insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    public var selectedTextColor = UIColor.black
    public var deselectedTextColor = UIColor.lightGray
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 16, weight: .bold)
    public var selectedViewInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
    public var selectedViewColor = UIColor(white: 0.9, alpha: 1) {
        didSet {
            selectedView.backgroundColor = selectedViewColor
        }
    }
    
    private(set) public var currentIndex: Int = 0
    private var titles: [String] = []
    private var selectedView = UIView()
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
        
        backgroundColor = .white
        
        collectionView.dataSource = self
        collectionView.delegate = self
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
        }
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(PinterestMenuViewCell.self)
        collectionView.backgroundColor = .clear
        
        selectedView.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        insertSubview(selectedView, at: 0)
        
        selectedView.backgroundColor = selectedViewColor
    }
    
    public func moveTo(fromIndex: Int, toIndex: Int, scrollPercentage: CGFloat, indexWasChanged: Bool) {
        if indexWasChanged {
            currentIndex = toIndex
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
        }
        
        // Scroll
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
        selectedView.center.x = pointX
        
        let inset = selectedViewInsets.left + selectedViewInsets.right
        let fromWidth = titleLabelSize(string: titles[fromIndex]).width + inset
        let toWidth = titleLabelSize(string: titles[toIndex]).width  + inset
        let width = (toWidth - fromWidth) * scrollPercentage + fromWidth
        selectedView.frame.size.width = width
    }
    
    public func sourceViewControllers(_ viewControllers: [UIViewController]) {
        titles = viewControllers
            .compactMap { $0 as? MenuTitleProvider }
            .map { $0.menuTitle }
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        
        updateSelectedView()
    }
    
    private func moveTo(fromIndex: Int, toIndex: Int, animated: Bool) {
        currentIndex = toIndex
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        
        // Scroll
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
        selectedView.center.x = fromPoint.x
        
        let inset = selectedViewInsets.left + selectedViewInsets.right
        let fromWidth = titleLabelSize(string: titles[fromIndex]).width + inset
        let toWidth = titleLabelSize(string: titles[toIndex]).width  + inset
        selectedView.frame.size.width = fromWidth

        
        if !animated {
            selectedView.frame.size.width = toWidth
            selectedView.center.x = toPoint.x
            return
        }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.selectedView.frame.size.width = toWidth
            self?.selectedView.center.x = toPoint.x
        }
    }
    
    private func updateSelectedView() {
        guard let cell = getCell(index: currentIndex) else { return }
        let point = cell.contentView.convert(cell.titleLabel.center, to: collectionView)
        selectedView.frame.size = CGSize(width: cell.titleLabel.bounds.width + selectedViewInsets.left + selectedViewInsets.right,
                                         height: cell.titleLabel.bounds.height + selectedViewInsets.top + selectedViewInsets.bottom)
        selectedView.center = point
        selectedView.layer.cornerRadius = selectedView.bounds.height / 2
    }
    
    private func getCell(index: Int) -> PinterestMenuViewCell? {
        return collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? PinterestMenuViewCell
    }
    
    private func getAttributes(index: Int) -> UICollectionViewLayoutAttributes? {
        return collectionView.layoutAttributesForItem(at: IndexPath(item: index, section: 0))
    }
    
    private func titleLabelSize(string: String) -> CGSize {
        return NSString(string: string).boundingRect(with: UIView.layoutFittingExpandedSize,
                                             options: .usesLineFragmentOrigin,
                                             attributes: [NSAttributedString.Key.font: titleFont],
                                             context: nil).size
    }
}

extension PinterestMenuView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(type: PinterestMenuViewCell.self, for: indexPath)
        cell.configure(title: titles[indexPath.item])
        cell.titleLabel.textColor = currentIndex == indexPath.item ? selectedTextColor : deselectedTextColor
        cell.titleLabel.font = titleFont
        return cell
    }
}

extension PinterestMenuView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch distribution {
        case .fillEqually:
            let numberOfItems = collectionView.numberOfItems(inSection: 0)
            let totalWidth = collectionView.bounds.width - insets.left - insets.right
            return CGSize(width: totalWidth / CGFloat(numberOfItems), height: collectionView.bounds.height)
        case .equalSpacing:
            let title = titles[indexPath.item]
            let rect = NSString(string: title).boundingRect(with: UIView.layoutFittingExpandedSize,
                                                            options: .usesLineFragmentOrigin,
                                                            attributes: [NSAttributedString.Key.font: titleFont],
                                                            context: nil)
            return CGSize(width: rect.width, height: collectionView.bounds.height)
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
        selectedView.frame.origin.x -= scrollView.contentOffset.x - lastContentOffsetX
        lastContentOffsetX = scrollView.contentOffset.x
    }
}
