//
//  UIColor.swift
//  Pager
//
//  Created by Yuto Akiba on 2019/07/14.
//  Copyright © 2019 Yuto Akiba. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hex: NSInteger, alpha: CGFloat = 1) {
        let r: Int = (hex >> 16)
        let g: Int = (hex >> 8 & 0xFF)
        let b: Int = (hex & 0xFF)
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: alpha)
    }
}
