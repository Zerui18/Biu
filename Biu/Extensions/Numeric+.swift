//
//  BinaryFloatingPoint.swift
//  Biu
//
//  Created by Zerui Chen on 23/8/20.
//

import UIKit

fileprivate let scalar: CGFloat = 1.5

extension BinaryInteger {
    /// Platformized.
    var p: CGFloat {
        return isPad ? CGFloat(self) * scalar : CGFloat(self)
    }
}

extension BinaryFloatingPoint {
    /// Platformized.
    var p: CGFloat {
        return isPad ? CGFloat(self) * scalar : CGFloat(self)
    }
}
