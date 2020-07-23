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
    
    init(placeholder: UIImage, url: URL) {
        image = .init(uiImage: placeholder)
        
        loadImageTask = ImagePipeline.shared.loadImage(with: url) { (response) in
            if let image = try? response.get().image {
                self.image = .init(uiImage: image)
            }
        }
    }
    
}
