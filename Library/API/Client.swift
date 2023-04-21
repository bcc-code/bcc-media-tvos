//
// Created by Fredrik Vedvik on 10/03/2023.
//

import Apollo
import Foundation

typealias TokenFactory = () async throws -> String?

private func mapLanguageToString(value: String) -> String {
    if let first = value.split(separator: "-").first {
        return String(first)
    }
    return "en"
}


private class NetworkInterceptorProvider: DefaultInterceptorProvider {
    var tokenFactory: TokenFactory

    init(tokenFactory: @escaping TokenFactory, client: URLSessionClient, store: ApolloStore) {
        self.tokenFactory = tokenFactory
        super.init(client: client, shouldInvalidateClientOnDeinit: true, store: store)
    }

    override func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        var interceptors = super.interceptors(for: operation)
        interceptors.insert(CustomInterceptor(tokenFactory: tokenFactory), at: 0)
        return interceptors
    }
}

private class CustomInterceptor: ApolloInterceptor {
    var tokenFactory: TokenFactory

    init(tokenFactory: @escaping TokenFactory) {
        self.tokenFactory = tokenFactory
    }

    func interceptAsync<Operation: GraphQLOperation>(
            chain: RequestChain,
            request: HTTPRequest<Operation>,
            response: HTTPResponse<Operation>?,
            completion: @escaping (Swift.Result<GraphQLResult<Operation.Data>, Error>) -> Void) {

        Task {
            do {
                if let c = try await tokenFactory() {
                    request.addHeader(name: "X-Application", value: "tvos")
                    request.addHeader(name: "Authorization", value: "Bearer " + c)
                }

                chain.proceedAsync(request: request,
                        response: response,
                        completion: completion)
            } catch {
                print(error)
            }
        }
    }
}

class ApolloClientFactory {
    var tokenFactory: TokenFactory

    init(tokenFactory: @escaping TokenFactory) {
        self.tokenFactory = tokenFactory
    }

    public func NewClient() -> ApolloClient {
        let apolloClientCache = InMemoryNormalizedCache()
        let store = ApolloStore(cache: apolloClientCache)
        let authPayloads = ["accept-language": Locale.preferredLanguages.map(mapLanguageToString).joined(separator: ",")]
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = authPayloads

        let client = URLSessionClient(sessionConfiguration: configuration, callbackQueue: nil)
        let provider = NetworkInterceptorProvider(tokenFactory: tokenFactory, client: client, store: store)

        let url = URL(string: "https://api.brunstad.tv/query")!

        let requestChainTransport = RequestChainNetworkTransport(interceptorProvider: provider,
                endpointURL: url)

        return ApolloClient(networkTransport: requestChainTransport,
                store: store)
    }

}
