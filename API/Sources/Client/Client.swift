import Apollo
import ApolloAPI
import Foundation

public typealias TokenFactory = () async throws -> String?
public typealias SessionIdFactory = () async throws -> String?
public typealias SearchSessionIdFactory = () async throws -> String?
/// Value for the `X-Feature-Flags` header, or nil to omit it.
///
/// Deliberately neither async nor throwing, to keep the header cheap to produce inside the request
/// pipeline.
public typealias FeatureFlagsFactory = () -> String?

/// Reports an error that this layer would otherwise only `print`.
///
/// Injected rather than calling Sentry here, because this package does not depend on it — the same
/// shape as `Authentication.Provider`'s `logger`. Called from the request pipeline, so it must not
/// assume it is on any particular thread.
public typealias ErrorReporter = (Error) -> Void

/// The `errors` array a GraphQL response can carry, as one `Error`.
///
/// Wrapped so a single failed operation reports as one event rather than one per error.
public struct GraphQLResponseError: Error, CustomStringConvertible {
    public let errors: [GraphQLError]

    public var description: String {
        let messages = errors.map { $0.message ?? "unknown GraphQL error" }
        return messages.joined(separator: "; ")
    }
}

public extension Client {
    func getAsync<Q: GraphQLQuery>(query: Q, cachePolicy: Apollo.CachePolicy = .fetchIgnoringCacheCompletely) async -> Q.Data? {
        return await withCheckedContinuation { c in
            self.apollo.fetch(query: query, cachePolicy: cachePolicy) { result in
                switch result {
                case let .success(response):
                    if let errors = response.errors {
                        self.reportError(GraphQLResponseError(errors: errors))
                    }
                    // A response may legally carry both `data` and `errors` — a nullable field's
                    // resolver failed while the rest resolved. Apollo leaves `data` nil only when it
                    // could not build a valid model at all, so hand back what it parsed rather than
                    // discarding the whole response. Resuming here on every path also keeps the fix
                    // for the case that used to resume nowhere and hang the caller for the life of
                    // the process.
                    c.resume(returning: response.data)
                case let .failure(err):
                    self.reportError(err)
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
    internal var reportError: ErrorReporter

    internal init(apollo: ApolloClient, reportError: @escaping ErrorReporter) {
        self.apollo = apollo
        self.reportError = reportError
    }
}

public func NewClient(
    apiUrl: String,
    tokenFactory: @escaping TokenFactory,
    sessionIdFactory: @escaping SessionIdFactory,
    searchSessionIdFactory: @escaping SearchSessionIdFactory,
    featureFlagsFactory: FeatureFlagsFactory? = nil,
    reportError: @escaping ErrorReporter = { print($0) }
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
        reportError: reportError,
        client: client,
        store: store
    )

    let url = URL(string: apiUrl)!

    let requestChainTransport = RequestChainNetworkTransport(interceptorProvider: provider,
                                                             endpointURL: url)

    return Client(
        apollo: ApolloClient(networkTransport: requestChainTransport, store: store),
        reportError: reportError
    )
}
