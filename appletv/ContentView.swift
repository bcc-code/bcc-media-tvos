//
//  ContentView.swift
//  appletv
//
//  Created by Fredrik Vedvik on 09/03/2023.
//
//

import SwiftUI

struct ContentView: View {
    @State var token = ""

    @State var page: API.GetPageQuery.Data.Page? = nil

    var authenticationProvider = AuthenticationProvider(options: AuthenticationProviderOptions(client_id: "HgmQSt1W0Is0zrQgWFw6J8AHE0PyjMRt", scope: "profile email", audience: "dev-api.bcc.no", domain: "bcc-sso-dev.eu.auth0.com"))

    var body: some View {
        VStack {
            if let p = page {
                List(p.sections.items, id: \.id) { section in
                    if let s = section.asItemSection {
                        ItemSectionView(section: s)
                    }
                }
            }
        }
        .task {
            apolloClient.fetch(query: API.GetPageQuery()) { result in
                switch result {
                case let .success(res):
                    if let p = res.data {
                        page = p.page
                    }
                case .failure:
                    print("FAILED")
                }

                print("OK")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
