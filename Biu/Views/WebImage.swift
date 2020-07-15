//
//  WebImage.swift
//  Biu
//
//  Created by Zerui Chen on 12/7/20.
//

import SwiftUI
import Nuke

class WebImage: ObservableObject {
    
    @Published var image: SwiftUI.Image?
    
    init(url: URL, size: CGSize) {
        let request = ImageRequest(url: url, processors: [ImageProcessors.Resize(height: size.height)])
        ImagePipeline.shared.loadImage(with: request) { (result) in
            self.image =  (try? result.get().image).flatMap(Image.init(uiImage:))
        }
    }
    
}
