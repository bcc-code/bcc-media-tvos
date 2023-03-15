//
// Created by Fredrik Vedvik on 10/03/2023.
//

import Apollo
import Foundation

class Network {
    static let shared = Network()

    private(set) lazy var apollo: ApolloClient = {
        let cache = InMemoryNormalizedCache()
        let store = ApolloStore(cache: cache)
        let authPayloads = ["x-application": "tvos"]
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = authPayloads

        let client = URLSessionClient(sessionConfiguration: configuration, callbackQueue: nil)
        let provider = NetworkInterceptorProvider(client: client, shouldInvalidateClientOnDeinit: true, store: store)

        let url = URL(string: "https://api.brunstad.tv/query")!

        let requestChainTransport = RequestChainNetworkTransport(interceptorProvider: provider,
                endpointURL: url)

        return ApolloClient(networkTransport: requestChainTransport,
                store: store)
    }()
}

class NetworkInterceptorProvider: DefaultInterceptorProvider {
    override func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        var interceptors = super.interceptors(for: operation)
        interceptors.insert(CustomInterceptor(), at: 0)
        return interceptors
    }
}

class CustomInterceptor: ApolloInterceptor {
    func interceptAsync<Operation: GraphQLOperation>(
            chain: RequestChain,
            request: HTTPRequest<Operation>,
            response: HTTPResponse<Operation>?,
            completion: @escaping (Swift.Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
//        request.addHeader(name: "Authorization", value: "Bearer <<TOKEN>>")
//        request.addHeader(name: "x-application", value: "tvos")
        Task {
            do {
                let code = try await authenticationProvider.getAccessToken()

                if let c = code {
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

let apolloClient = Network.shared.apollo
