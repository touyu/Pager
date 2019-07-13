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
    public weak var delegate: MenuProviderDelegate?
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    public var insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    public var selectedTextColor = UIColor.black
    public var deselectedTextColor = UIColor.lightGray
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 18, weight: .bold)
    public var selectedViewInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
    public var selectedViewColor = UIColor(white: 0.9, alpha: 1) {
        didSet {
            selectedView.backgroundColor = selectedViewColor
        }
    }
    
    private(set) public var currentIndex: Int = 0
    private var titles: [String] = []
    private var selectedView = UIView()
    
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
        collectionView.isScrollEnabled = false
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
        
        guard let fromCell = collectionView.cellForItem(at: IndexPath(item: fromIndex, section: 0)) as? PinterestMenuViewCell else { return }
        guard let toCell = collectionView.cellForItem(at: IndexPath(item: toIndex, section: 0)) as? PinterestMenuViewCell else { return }
        let fromPoint = fromCell.contentView.convert(fromCell.titleLabel.center, to: collectionView)
        let toPoint = toCell.contentView.convert(toCell.titleLabel.center, to: collectionView)
        
        let pointX = (toPoint.x - fromPoint.x) * scrollPercentage + fromPoint.x
        selectedView.center.x = pointX
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
        
        guard let fromCell = collectionView.cellForItem(at: IndexPath(item: fromIndex, section: 0)) as? PinterestMenuViewCell else { return }
        guard let toCell = collectionView.cellForItem(at: IndexPath(item: toIndex, section: 0)) as? PinterestMenuViewCell else { return }
        let fromPoint = fromCell.contentView.convert(fromCell.titleLabel.center, to: collectionView)
        let toPoint = toCell.contentView.convert(toCell.titleLabel.center, to: collectionView)
        selectedView.center.x = fromPoint.x
        
        if !animated {
            selectedView.center.x = toPoint.x
            return
        }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.selectedView.center.x = toPoint.x
        }
    }
    
    private func updateSelectedView() {
        guard let cell = collectionView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? PinterestMenuViewCell else { return }
        let point = cell.contentView.convert(cell.titleLabel.center, to: collectionView)
        selectedView.frame.size = CGSize(width: cell.titleLabel.bounds.width + selectedViewInsets.left + selectedViewInsets.right,
                                         height: cell.titleLabel.bounds.height + selectedViewInsets.top + selectedViewInsets.bottom)
        selectedView.center = point
        selectedView.layer.cornerRadius = selectedView.bounds.height / 2
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
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        let totalWidth = collectionView.bounds.width - insets.left - insets.right
        return CGSize(width: totalWidth / CGFloat(numberOfItems), height: collectionView.bounds.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
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
}
