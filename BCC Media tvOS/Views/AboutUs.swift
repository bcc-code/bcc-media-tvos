//
//  AboutUs.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 16/05/2023.
//

import SwiftUI

struct AboutUsView: View {
    @Environment(\.dismiss) private var dismiss

    // Computed rather than stored, and `String(localized:)` rather than `NSLocalizedString`, to match
    // the rest of the app. As stored properties these resolved when the view value was created rather
    // than when the body runs, and they showed up in the memberwise initialiser.
    private var contactString: String { String(localized: "aboutUs_contact") }
    private var privacyPolicyString: String { String(localized: "aboutUs_privacyPolicy") }
    private var termsOfUseString: String { String(localized: "aboutUs_termsOfUse") }

    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            Spacer()
            VStack(alignment: .leading, spacing: 40) {
                // The asset is named "LogoBanner"; the ".png" suffix matched nothing, so the force
                // unwrap here was almost certainly trapping whenever this screen was opened.
                Image("LogoBanner")
                    .resizable()
                    .frame(width: 970, height: 346)
                Text("aboutUs_description")
                Text(contactString.split(separator: "$email")[0])
                    + Text("support@bcc.media").foregroundColor(.blue)
                    + Text(contactString.split(separator: "$email")[1])
                Text(privacyPolicyString.split(separator: "$url")[0])
                    + Text("bcc.media/en/privacy").foregroundColor(.blue)
                Text(termsOfUseString.split(separator: "$url")[0])
                    + Text("bcc.media/en/terms-of-use").foregroundColor(.blue)
            }.focusable().font(.barlow)
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Text("common_back")
                }
            }
            Spacer()
        }.frame(width: 970)
            .onAppear {
                Events.page("about-us")
            }
    }
}

struct AboutUsView_Previews: PreviewProvider {
    static var previews: some View {
        AboutUsView()
    }
}
