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

    private var localizedGotoString: String { String(localized: "signIn_orGoToAndEnterCode") }

    /// The sign-in sentence carries two placeholders: `$url`, inlined here, and `$code`, shown on its
    /// own below — so everything from `$code` onwards is dropped deliberately.
    ///
    /// Previously `split(separator: "$url")[1]`, which trapped if a translator dropped `$url`. This is
    /// the login screen, so that crash would have been unrecoverable for the affected locale.
    private var gotoText: Text {
        let aroundUrl = localizedGotoString.splitAroundPlaceholder("$url")
        let beforeCode = aroundUrl.after.splitAroundPlaceholder("$code").before
        return Text(aroundUrl.before)
            + Text(getSimpleUri()).foregroundColor(.blue)
            + Text(beforeCode)
    }

    @Environment(\.dismiss) var dismiss

    var body: some View {
        HStack {
            VStack {
                if let img = getQRCodeData(text: verificationUriComplete), let qr = UIImage(data: img) {
                    Image(uiImage: qr).resizable().frame(width: 512, height: 512).cornerRadius(10).shadow(radius: 20)
                }
                Text("signIn_scanWithPhone").foregroundColor(.gray)
            }
            Spacer().frame(width: 50)
            VStack {
                gotoText
                Spacer().frame(height: 30)
                Text(code).accessibilityIdentifier("LoginCode").accessibilityLabel(code).font(.barlowTitle)
                Spacer().frame(height: 100)
                Button("Cancel") {
                    dismiss()
                }
            }
        }.frame(width: 1200, height: 800).onDisappear {
            cancel()
        }.onAppear {
            Events.page("login")
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
