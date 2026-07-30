import Apollo
import ApolloAPI
import Foundation

public typealias TokenFactory = () async throws -> String?
public typealias SessionIdFactory = () async throws -> String?
public typealias SearchSessionIdFactory = () async throws -> String?
/// Value for the `X-Feature-Flags` header, or nil to omit it.
///
/// Deliberately neither async nor throwing: the interceptor's `catch` swallows errors without
/// continuing the request chain, so a throwing factory here would hang requests.
public typealias FeatureFlagsFactory = () -> String?

public extension Client {
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
                    } else {
                        // Neither data nor errors: without this the continuation was never resumed and
                        // the caller hung for the life of the process.
                        c.resume(returning: nil)
                    }
                case let .failure(err):
                    print(err)
                    c.resume(returning: nil)
                }
            }
        }
    }

    func perform<M: GraphQLMutation>(mutation: M) {
        apollo.perform(mutation: mutation)
    }

    func clearCache(callbackQueue: DispatchQueue = .main, callback: @escaping () -> Void) {
        apollo.clearCache { _ in
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

public func NewClient(
    apiUrl: String,
    tokenFactory: @escaping TokenFactory,
    sessionIdFactory: @escaping SessionIdFactory,
    searchSessionIdFactory: @escaping SearchSessionIdFactory,
    featureFlagsFactory: FeatureFlagsFactory? = nil
) -> Client {
    let apolloClientCache = InMemoryNormalizedCache()
    let store = ApolloStore(cache: apolloClientCache)
    let configuration = URLSessionConfiguration.default

    let client = URLSessionClient(sessionConfiguration: configuration, callbackQueue: nil)
    let provider = NetworkInterceptorProvider(
        tokenFactory: tokenFactory,
        sessionIdFactory: sessionIdFactory,
        searchSessionIdFactory: searchSessionIdFactory,
        featureFlagsFactory: featureFlagsFactory,
        client: client,
        store: store
    )

    let url = URL(string: apiUrl)!

    let requestChainTransport = RequestChainNetworkTransport(interceptorProvider: provider,
                                                             endpointURL: url)

    return Client(apollo: ApolloClient(networkTransport: requestChainTransport,
                                       store: store))
}
