//
//  AboutUs.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 16/05/2023.
//

import SwiftUI

struct AboutUsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            Spacer()
            VStack(alignment: .leading, spacing: 40) {
                Image(uiImage: UIImage(named: "LogoBanner.png")!)
                    .resizable()
                    .frame(width: 970, height: 346)
                Text("aboutUs_description").font(.callout)
                Text("aboutUs_contact").font(.callout)
                Text("aboutUs_privacyPolicy").font(.callout)
            }.focusable()
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
    }
}

extension AboutUsView: Hashable {
    static func == (lhs: AboutUsView, rhs: AboutUsView) -> Bool {
        true
    }

    func hash(into hasher: inout Hasher) {
        
    }
}

struct AboutUsView_Previews: PreviewProvider {
    static var previews: some View {
        AboutUsView()
    }
}
