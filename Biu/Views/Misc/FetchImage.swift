//
//  FetchImage.swift
//  Biu
//
//  Created by Zerui Chen on 15/7/20.
//

import SwiftUI
import Nuke

final class FetchImage: ObservableObject {
    
    @Published var image: SwiftUI.Image
    
    private var loadImageTask: Any?
    
    /// Init with a placeholder UIImage and url for network image.
    init(url: URL, placeholder: UIImage = UIImage(named: "bg_placeholder")!) {
        image = .init(uiImage: placeholder)
        
        loadImageTask = ImagePipeline.shared.loadImage(with: url) { (response) in
            if let image = try? response.get().image {
                self.image = .init(uiImage: image)
            }
        }
    }
    
    
    /// Init with an Image.
    init(image: SwiftUI.Image) {
        self.image = image
    }
    
}
