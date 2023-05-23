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

    func getSimpleUri() -> String {
        var str = verificationUri
        str.replace("https://", with: "")
        return str
    }

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

    var localizedGotoString = NSLocalizedString("signIn_orGoToAndEnterCode", comment: "")

    var body: some View {
        HStack {
            VStack {
                if let img = getQRCodeData(text: verificationUriComplete) {
                    Image(uiImage: UIImage(data: img)!).resizable().frame(width: 512, height: 512).cornerRadius(10).shadow(radius: 20)
                }
                Text("signIn_scanWithPhone").foregroundColor(.gray)
            }
            Spacer().frame(width: 50)
            VStack {
                Group {
                    Text(localizedGotoString.split(separator: "$url")[0]) +
                        Text(getSimpleUri()).foregroundColor(.blue) +
                        Text(localizedGotoString.split(separator: "$url")[1].split(separator: "$code")[0])
                }
                Spacer().frame(height: 30)
                Text(code).font(.title)
                Spacer().frame(height: 100)
                Button("Cancel") {
                    cancel()
                }
            }
        }.frame(width: 1200, height: 800)
    }
}

extension SignInView: Hashable {
    static func == (_: SignInView, _: SignInView) -> Bool {
        true
    }

    func hash(into _: inout Hasher) {}
}

struct SignInView_Preview: PreviewProvider {
    static var previews: some View {
        SignInView(cancel: {}, verificationUri: "https://login.bcc.no/activate", verificationUriComplete: "https://login.bcc.no/asd", code: "1234-1234")
    }
}
