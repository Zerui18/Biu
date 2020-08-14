//
//  String+Alphabets.swift
//  Biu
//
//  Created by Zerui Chen on 11/8/20.
//

import Foundation

extension String {
    
    func toLatin()-> String {
        let cfString = NSMutableString(string: self) as CFMutableString
        CFStringTransform(cfString, nil, kCFStringTransformToLatin, false)
        CFStringTransform(cfString, nil, kCFStringTransformStripCombiningMarks, false)
        return cfString as String
    }
    
}
