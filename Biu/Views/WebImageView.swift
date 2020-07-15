//
//  FetchImage.swift
//  Biu
//
//  Created by Zerui Chen on 8/7/20.
//

import SwiftUI
import Nuke

final class WebImageView: UIViewRepresentable {
    
    let imageView = UIImageView()
    
    init(url: URL) {
        imageView.backgroundColor = .systemFill
        imageView.contentMode = .scaleToFill
        let request = ImageRequest(url: url)
        ImagePipeline.shared.loadImage(with: request) { (result) in
            self.imageView.image = try? result.get().image
        }
    }
    
    func makeUIView(context: Context) -> UIImageView {
        imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
    }
    
}
