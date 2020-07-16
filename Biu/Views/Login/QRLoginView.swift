//
//  QRLoginView.swift
//  Biu
//
//  Created by Zerui Chen on 3/7/20.
//

import SwiftUI

struct QRLoginView: View {
    
    @ObservedObject var modal = LoginModel.shared
    
    var body: some View {
        VStack {
            if modal.qrCodeImage != nil {
                modal.qrCodeImage!
                    .frame(width: 200, height: 200)
                    .cornerRadius(8, antialiased: true)
            }
            else {
                Text("Generating QR Code")
            }
        }
        .animation(.easeInOut)
        .transition(.slide)
        .onAppear {
            modal.beginQRCodeGeneration()
        }
    }
}

struct QRLoginView_Previews: PreviewProvider {
    static var previews: some View {
        QRLoginView()
    }
}
