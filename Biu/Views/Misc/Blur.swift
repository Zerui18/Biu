//
//  Blur.swift
//  Bili
//
//  Created by Zerui Chen on 3/7/20.
//
import SwiftUI

struct Blur: UIViewRepresentable {
    
    @Environment(\.colorScheme) var colorScheme

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark:.light))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
    }
}
