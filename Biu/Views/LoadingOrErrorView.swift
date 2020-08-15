//
//  LoadingOrErrorView.swift
//  Biu
//
//  Created by Zerui Chen on 12/8/20.
//

import SwiftUI
import BiliKit

struct LoadingOrErrorView: View {
    
    @Binding var error: BKError?
    
    var body: some View {
        VStack(spacing: 10) {
            // Error.
            if let error = error {
                Text(error.title)
                    .font(.headline)
                if let message = error.message {
                    Text(message)
                        .font(.subheadline)
                }
            }
            // Loading.
            else {
                Text("Loading")
            }
        }
    }
}

struct LoadingOrErrorView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingOrErrorView(error: .constant(.networkError(reason: "Loli is justice :)")))
    }
}
