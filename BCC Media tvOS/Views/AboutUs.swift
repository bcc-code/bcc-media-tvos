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

    /// A localized template with its placeholder replaced by a highlighted value.
    ///
    /// Replaces three hand-rolled `split(...)[0]` / `[1]` pairs. Besides the crash, the privacy and
    /// terms lines only rendered the part *before* the placeholder, so a translation with anything
    /// after the URL silently lost it.
    private func templated(_ template: String, placeholder: String, value: String) -> Text {
        let parts = template.splitAroundPlaceholder(placeholder)
        return Text(parts.before) + Text(value).foregroundColor(.blue) + Text(parts.after)
    }

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
                templated(contactString, placeholder: "$email", value: "support@bcc.media")
                templated(privacyPolicyString, placeholder: "$url", value: "bcc.media/en/privacy")
                templated(termsOfUseString, placeholder: "$url", value: "bcc.media/en/terms-of-use")
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
