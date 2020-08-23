//
//  String+.swift
//  Biu
//
//  Created by Zerui Chen on 11/8/20.
//

import Foundation

extension String {
    
    /// Transform the string to latin.
    func toLatin()-> String {
        let cfString = NSMutableString(string: self) as CFMutableString
        CFStringTransform(cfString, nil, kCFStringTransformToLatin, false)
        CFStringTransform(cfString, nil, kCFStringTransformStripCombiningMarks, false)
        return cfString as String
    }
    
    /// Remove extra text that's usually found between brackets.
    func cleanedTitle()-> String {
        replacingMatches(of: bracketsRegex)
            .replacingMatches(of: squareBracketsRegex)
    }
    
    func replacingMatches(of pattern: NSRegularExpression, with string: String = "") -> String {
        let range = NSMakeRange(0, count)
        return pattern.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: string)
    }
    
}

fileprivate let bracketsRegex = try! NSRegularExpression(pattern: "(（.+?）)", options: [])
fileprivate let squareBracketsRegex = try! NSRegularExpression(pattern: "(【.+?】)", options: [])
