//
//  String+QRCode.swift
//  BiliKit
//
//  Created by Zerui Chen on 19/7/20.
//

import UIKit

// MARK: QRCode Generation
fileprivate let ciContext = CIContext()

extension String {
    
    func generateQRCode() -> UIImage? {
        let data = self.data(using: String.Encoding.utf8)
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        qrFilter.setValue(data, forKey: "inputMessage")

        guard let ciImage = qrFilter.outputImage?.transformed(by: CGAffineTransform(scaleX: 4, y: 4)) else { return nil }
        let cgImage = ciContext
            .createCGImage(ciImage, from: ciImage.extent)

        let uiImage = UIImage(cgImage: cgImage!)

        return uiImage
    }
    
}
