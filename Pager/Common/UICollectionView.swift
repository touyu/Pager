//
//  UICollectionView.swift
//  Pager
//
//  Created by Yuto Akiba on 2019/07/14.
//  Copyright © 2019 Yuto Akiba. All rights reserved.
//

import UIKit

enum CollectionElementKindSection: CustomStringConvertible {
    case header
    case footer
    
    public var description: String {
        switch self {
        case .header:
            return UICollectionView.elementKindSectionHeader
        case .footer:
            return UICollectionView.elementKindSectionFooter
        }
    }
}

extension UICollectionView {
    func register(_ cellTypes: UICollectionViewCell.Type...) {
        cellTypes.forEach {
            registerNib(type: $0)
        }
    }
    
    private func registerNib<T: UICollectionViewCell>(type: T.Type) {
        let bundle = Bundle(for: type)
        let nib = UINib(nibName: type.className, bundle: bundle)
        register(nib, forCellWithReuseIdentifier: type.className)
    }
    
    func registerNib<T: UICollectionReusableView>(type: T.Type, for kind: CollectionElementKindSection) {
        let bundle = Bundle(for: type)
        let nib = UINib(nibName: type.className, bundle: bundle)
        register(nib, forSupplementaryViewOfKind: kind.description, withReuseIdentifier: type.className)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(type: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: type.className, for: indexPath) as! T
    }
    
    func dequeueReusableCell<T: UICollectionReusableView>(kind: String, withReuseType type: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: type.className, for: indexPath) as! T
    }
    
    func dequeueReusableCell<T: UICollectionReusableView>(kind: CollectionElementKindSection, withReuseType type: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableSupplementaryView(ofKind: kind.description, withReuseIdentifier: type.className, for: indexPath) as! T
    }
}
