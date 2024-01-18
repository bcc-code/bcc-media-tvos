import ApolloAPI
import Apollo
import Foundation

public typealias TokenFactory = () async throws -> String?

public extension Client {
    func getThrowingAsync<Q: API.GraphQLQuery>(query: Q, cachePolicy: Apollo.CachePolicy = .default) async throws -> Q.Data {
        return try await withCheckedThrowingContinuation { c in
            self.apollo.fetch(query: query, cachePolicy: cachePolicy) { result in
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
    
    func getAsync<Q: GraphQLQuery>(query: Q, cachePolicy: Apollo.CachePolicy = .fetchIgnoringCacheCompletely) async -> Q.Data? {
        return await withCheckedContinuation { c in
            self.apollo.fetch(query: query, cachePolicy: cachePolicy) { result in
                switch result {
                case let .success(data):
                    if let errors = data.errors {
                        print(errors)
                        c.resume(returning: nil)
                    } else if let data = data.data {
                        c.resume(returning: data)
                    }
                case let .failure(err):
                    print(err)
                    c.resume(returning: nil)
                }
            }
        }
    }
    
    func perform<M : GraphQLMutation>(mutation: M) {
        apollo.perform(mutation: mutation)
    }
    
    func clearCache(callbackQueue: DispatchQueue = .main, callback: @escaping () -> Void) {
        apollo.clearCache() { _ in
            callback()
        }
    }
}
public struct Client {
    internal var apollo: ApolloClient
    
    internal init(apollo: ApolloClient) {
        self.apollo = apollo
    }
}

public func NewClient(apiUrl: String, tokenFactory: @escaping TokenFactory) -> Client {
    let apolloClientCache = InMemoryNormalizedCache()
    let store = ApolloStore(cache: apolloClientCache)
    let configuration = URLSessionConfiguration.default

    let client = URLSessionClient(sessionConfiguration: configuration, callbackQueue: nil)
    let provider = NetworkInterceptorProvider(tokenFactory: tokenFactory, client: client, store: store)

    let url = URL(string: apiUrl)!

    let requestChainTransport = RequestChainNetworkTransport(interceptorProvider: provider,
            endpointURL: url)

    return Client(apollo: ApolloClient(networkTransport: requestChainTransport,
                                       store: store))
}

