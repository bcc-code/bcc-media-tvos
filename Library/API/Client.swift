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
                
                request.addHeader(name: "Accept-Language", value: Locale.current.identifier)
                
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
    var apiUrl: String
    
    init(_ apiUrl: String, tokenFactory: @escaping TokenFactory) {
        self.apiUrl = apiUrl
        self.tokenFactory = tokenFactory
    }

    public func NewClient() -> ApolloClient {
        let apolloClientCache = InMemoryNormalizedCache()
        let store = ApolloStore(cache: apolloClientCache)
        let configuration = URLSessionConfiguration.default

        let client = URLSessionClient(sessionConfiguration: configuration, callbackQueue: nil)
        let provider = NetworkInterceptorProvider(tokenFactory: tokenFactory, client: client, store: store)

        let url = URL(string: apiUrl)!

        let requestChainTransport = RequestChainNetworkTransport(interceptorProvider: provider,
                endpointURL: url)

        return ApolloClient(networkTransport: requestChainTransport,
                store: store)
    }

}

extension ApolloClient {
    func getThrowingAsync<Q: GraphQLQuery>(query: Q, cachePolicy: CachePolicy = .default) async throws -> Q.Data {
        return try await withCheckedThrowingContinuation { c in
            apolloClient.fetch(query: query, cachePolicy: cachePolicy) { result in
                switch result {
                case let .success(data):
                    if let data = data.data {
                        c.resume(returning: data)
                    }
                    if let errors = data.errors {
                        print(errors)
                    }
                case let .failure(err):
                    c.resume(throwing: err)
                }
            }
        }
    }
    
    func getAsync<Q: GraphQLQuery>(query: Q, cachePolicy: CachePolicy = .default) async -> Q.Data? {
        return await withCheckedContinuation { c in
            apolloClient.fetch(query: query, cachePolicy: cachePolicy) { result in
                switch result {
                case let .success(data):
                    if let data = data.data {
                        c.resume(returning: data)
                    }
                    if let errors = data.errors {
                        print(errors)
                        c.resume(returning: nil)
                    }
                case let .failure(err):
                    print(err)
                    c.resume(returning: nil)
                }
            }
        }
    }
}
