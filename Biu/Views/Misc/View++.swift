//
//  View++.swift
//  Biu
//
//  Created by Zerui Chen on 20/8/20.
//

import SwiftUI

extension View {
    
    func makeInteractive(media: MediaRepresentable) -> some View {
        #if targetEnvironment(macCatalyst)
        return onTapGesture {
            MediaPlayerModel.shared.replaceQueue(withMedia: media)
        }
        #else
        return onTapGesture(count: 2) {
            MediaPlayerModel.shared.addToQueue(media)
        }
        .onTapGesture {
            MediaPlayerModel.shared.replaceQueue(withMedia: media)
        }
        .onLongPressGesture {
            PopMenuModel.shared.selectedMedia = media
        }
        #endif
    }
    
    func card(cornerRadius: CGFloat = 10.p) -> some View {
        return padding(10.p)
            .background(
                Color(.secondarySystemBackground)
                    .cornerRadius(cornerRadius)
            )
    }
    
    /// Apply transform t and if condition is true, else return identity.
    func mapIf<Result: View>(_ condition: Bool, _ t: (Self) -> Result) -> some View {
        Group {
            if condition {
                t(self)
            }
            else {
                self
            }
        }
    }
    
}
