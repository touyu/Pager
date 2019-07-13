//
//  NibLoadable.swift
//  Pager
//
//  Created by Yuto Akiba on 2019/07/14.
//  Copyright © 2019 Yuto Akiba. All rights reserved.
//

import UIKit

protocol NibOwnerLoadable {}

extension NibOwnerLoadable where Self: UIView {
    var _viewID: String {
        return "loadedNibView"
    }
    
    var nibView: UIView? {
        return subviews.filter { $0.restorationIdentifier == _viewID }.first
    }
    
    func loadNib() {
        let bundle = Bundle(for: type(of: self))
        guard let view = UINib(nibName: self.className, bundle: bundle).instantiate(withOwner: self, options: nil).first as? UIView else {
            fatalError("not load nib")
        }
        view.restorationIdentifier = _viewID
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        self.addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            view.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        ])
    }
}
