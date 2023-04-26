//
//  ContentProvider.swift
//  Top Shelf
//
//  Created by Fredrik Vedvik on 25/04/2023.
//

import TVServices

struct AuthConfig {
    var domain: String = "login.bcc.no"
    var clientId: String = "rJbKSHYPskua2BgY8mEwOSasK6o6uCRA"
    var audience: String = "api.bcc.no"
}

let authConfig = AuthConfig()

let authenticationProvider = AuthenticationProvider(options: AuthenticationProviderOptions(client_id: authConfig.clientId, scope: "openid profile email offline_access", audience: authConfig.audience, domain: authConfig.domain))

class ContentProvider: TVTopShelfContentProvider {

    override func loadTopShelfContent(completionHandler: @escaping (TVTopShelfContent?) -> Void) {
        // Fetch content and call completionHandler
        Task {
            if authenticationProvider.isAuthenticated() {
                let item = TVTopShelfItem(identifier: "one")

                item.title = "One"
                item.setImageURL(URL(string: "https://brunstadtv.imgix.net/3e058c00-a047-4bfe-aed7-3371021f0cc7.jpg"), for: .screenScale2x)

                completionHandler(TVTopShelfInsetContent(items: [item]));
            } else {
                let item = TVTopShelfItem(identifier: "one")

                item.title = "One"
                item.setImageURL(URL(string: "https://brunstadtv.imgix.net/658d0ad0-5132-4ca0-96e1-6889d902a628.jpg"), for: .screenScale2x)

                completionHandler(TVTopShelfInsetContent(items: [item]));
            }
        }
    }

}

