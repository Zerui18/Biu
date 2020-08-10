//
//  RootTabItem.swift
//  Biu
//
//  Created by Zerui Chen on 28/7/20.
//

import SwiftUI

struct RootTabItem: View {
    
    let index: Int
    let image: Image
    let imageHighlighted: Image
    let label: Text
    
    @ObservedObject var rootModel = RootModel.shared
    
    var body: some View {
        VStack {
            rootModel.selectedPage == index ? imageHighlighted : image
            label
        }
    }
    
}
