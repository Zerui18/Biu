//
//  TimeInterval+Format.swift
//  Biu
//
//  Created by Zerui Chen on 19/8/20.
//

import Foundation

extension TimeInterval {
    func formattedDuration() -> String {
        let intSelf = Int(self)
        let (hours, remainder) = intSelf.quotientAndRemainder(dividingBy: 3600)
        let (minutes, seconds) = remainder.quotientAndRemainder(dividingBy: 60)
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
