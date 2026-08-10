//
//  Utils.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 22/06/2023.
//
import SwiftUI

extension String {
    /// Splits a localized template around a placeholder, as `(before, after)`.
    ///
    /// These templates come from Crowdin, so a placeholder is not guaranteed to survive translation. A
    /// missing one used to crash the screen through a force-indexed `split(…)[1]`; here it just means
    /// the whole string comes back as `before`, so the sentence still renders — without the value
    /// inlined into the middle of it.
    ///
    /// `components(separatedBy:)` rather than `split(separator:)` on purpose: `split` omits empty
    /// subsequences, so a template *beginning* with the placeholder handed back its trailing text as
    /// element zero, which would render in the leading position.
    func splitAroundPlaceholder(_ placeholder: String) -> (before: String, after: String) {
        let parts = components(separatedBy: placeholder)
        guard parts.count > 1 else {
            return (self, "")
        }
        // Rejoined past the first occurrence, so a duplicated placeholder loses no text.
        return (parts[0], parts.dropFirst().joined(separator: placeholder))
    }
}

public func getQRCodeData(text: String) -> Data? {
    guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
    let data = text.data(using: .ascii, allowLossyConversion: false)
    filter.setValue(data, forKey: "inputMessage")
    guard let ciimage = filter.outputImage else { return nil }
    let transform = CGAffineTransform(scaleX: 10, y: 10)
    let scaledCIImage = ciimage.transformed(by: transform)
    let uiimage = UIImage(ciImage: scaledCIImage)
    return uiimage.pngData()
}
