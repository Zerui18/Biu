//
//  PopMenuModel.swift
//  Biu
//
//  Created by Zerui Chen on 23/8/20.
//

import Foundation

class PopMenuModel: ObservableObject {

    static let shared = PopMenuModel()
    
    private init() {}
    
    @Published var selectedMedia: MediaRepresentable? = nil
    
}
