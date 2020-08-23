//
//  CGSize+.swift
//  Biu
//
//  Created by Zerui Chen on 17/7/20.
//

import UIKit

extension CGFloat {
    
    var compressed: CGFloat {
        tanh(self) * 10
    }
}

extension CGSize {
    
    var compressed: CGSize {
        CGSize(width: width.compressed, height: height.compressed)
    }
    
    /// Platformized.
    var p: CGSize {
        CGSize(width: width.p, height: height.p)
    }
    
}
