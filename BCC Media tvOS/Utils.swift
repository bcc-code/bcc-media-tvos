//
//  Utils.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 22/06/2023.
//
import SwiftUI

public func getAgeGroup(_ age: Int?) -> String {
    let breakpoints: [Int: String] = [
        9: "< 10",
        12: "10 - 12",
        18: "13 - 18",
        25: "19 - 25",
        36: "26 - 36",
        50: "37 - 50",
        64: "51 - 64",
    ]
    
    if let age = age {
        for (key, value) in breakpoints {
            if age <= key {
                return value
            }
        }
        return "65+"
    }
    return "UNKNOWN"
}

public func getQRCodeData(text: String) -> Data? {
    guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
    let data = text.data(using: .ascii, allowLossyConversion: false)
    filter.setValue(data, forKey: "inputMessage")
    guard let ciimage = filter.outputImage else { return nil }
    let transform = CGAffineTransform(scaleX: 10, y: 10)
    let scaledCIImage = ciimage.transformed(by: transform)
    let uiimage = UIImage(ciImage: scaledCIImage)
    return uiimage.pngData()!
}
