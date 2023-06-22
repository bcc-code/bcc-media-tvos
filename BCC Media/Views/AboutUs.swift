//
//  AboutUs.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 16/05/2023.
//

import SwiftUI

struct AboutUsView: View {
    @Environment(\.dismiss) private var dismiss

    var contactString = NSLocalizedString("aboutUs_contact", comment: "")
    var privacyPolicyString = NSLocalizedString("aboutUs_privacyPolicy", comment: "")

    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            Spacer()
            VStack(alignment: .leading, spacing: 40) {
                Image(uiImage: UIImage(named: "LogoBanner.png")!)
                    .resizable()
                    .frame(width: 970, height: 346)
                Text("aboutUs_description")
                Text(contactString.split(separator: "$email")[0])
                    + Text("support@bcc.media").foregroundColor(.blue)
                    + Text(contactString.split(separator: "$email")[1])
                Text(privacyPolicyString.split(separator: "$url")[0])
                    + Text("bcc.media/no/personvern").foregroundColor(.blue)
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
