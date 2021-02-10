//
//  PlatformFont.swift
//  Biu
//
//  Created by Zerui Chen on 22/8/20.
//

import SwiftUI

extension Font {
    
    #if targetEnvironment(macCatalyst)
    static let platformTitle = Font.system(size: 35)
    static let platformItemTitle = Font.system(size: 20)
    static let platformItemDesc = Font.system(size: 18)
    
    #elseif canImport(UIKit)
    static let platformTitle = Font.headline
    static let platformItemTitle = Font.subheadline
    static let platformItemDesc = Font.caption
    #endif
    
}
