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

    var localizedGotoString = NSLocalizedString("signIn_orGoToAndEnterCode", comment: "")

    @Environment(\.dismiss) var dismiss

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
                Text(code).font(.barlowTitle)
                Spacer().frame(height: 100)
                Button("Cancel") {
                    dismiss()
                }
            }
        }.frame(width: 1200, height: 800).onDisappear {
            cancel()
        }
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
