//
//  RootModel.swift
//  Biu
//
//  Created by Zerui Chen on 28/7/20.
//

import SwiftUI

class RootModel: ObservableObject {
    
    static let shared = RootModel()
    
    private init() {
    }
    
    lazy var selectionBinding = Binding<Int>.init
                                    { self.selectedPage }
                                set: { self.selectedPage = $0 }
    
    @Published var selectedPage = 1
    
}
