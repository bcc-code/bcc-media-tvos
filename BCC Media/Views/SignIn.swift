//
//  SignIn.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 20/03/2023.
//

import SwiftUI

struct SignInView: View {
    var cancel: () -> Void

    var verificationUri: String
    var verificationUriComplete: String
    var code: String
    
    func getQRCodeData(text: String) -> Data? {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        let data = text.data(using: .ascii, allowLossyConversion: false)
        filter.setValue(data, forKey: "inputMessage")
        guard let ciimage = filter.outputImage else { return nil }
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledCIImage = ciimage.transformed(by: transform)
        let uiimage = UIImage(ciImage: scaledCIImage)
        return uiimage.pngData()!
    }
    
    var body: some View {
        HStack {
            VStack {
                if let img = getQRCodeData(text: verificationUriComplete) {
                    Image(uiImage: UIImage(data: img)!).resizable().frame(width: 512, height: 512).shadow(radius:10)
                }
                Text("Or go to: " + verificationUri)
            }
            VStack {
                Text(code)
                Button("Back") {
                    cancel()
                }
            }
        }
    }
}
