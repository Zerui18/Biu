//
//  Int+DurationFormat.swift
//  Biu
//
//  Created by Zerui Chen on 16/7/20.
//

import Foundation

// MARK: Int + Format
extension Int {
    func formattedDuration() -> String {
        let (hours, remainder) = self.quotientAndRemainder(dividingBy: 3600)
        let (minutes, seconds) = remainder.quotientAndRemainder(dividingBy: 60)
        if hours > 0 {
            return "\(hours)h \(minutes):\(seconds)"
        }
        else {
            return "\(minutes):\(seconds)"
        }
    }
}
