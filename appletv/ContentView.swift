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

    var authenticationProvider = AuthenticationProvider(options: AuthenticationProviderOptions(client_id: "HgmQSt1W0Is0zrQgWFw6J8AHE0PyjMRt", scope: "profile email", audience: "dev-api.bcc.no", domain: "bcc-sso-dev.eu.auth0.com"))

    var body: some View {
        HStack {
            VStack {
                Text("Test")
            }
            VStack {
                Image(systemName: "globe")
                        .imageScale(.large)
                        .foregroundColor(.accentColor)
                Text("Hello, world!").font(.title)
                Text("Subtitle").font(.subheadline)
                Text(token).font(.title3)
            }
        }
                .padding()
                .task {
                    apolloClient.fetch(query: API.GetPageQuery) { result in

                    }
                }
//                .task {
//                    do {
//                        try await authenticationProvider.login(codeCallback: { result in
//                            token = result
//                        })
//                        print("LOGGED IN!")
//                    } catch {
//                        print(error)
//                    }
//                }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
