import Foundation
import Apollo

internal class NetworkInterceptorProvider: DefaultInterceptorProvider {
    var tokenFactory: TokenFactory
    var sessionIdFactory: SessionIdFactory?
    var searchSessionIdFactory: SearchSessionIdFactory?

    init(
        tokenFactory: @escaping TokenFactory,
        sessionIdFactory: SessionIdFactory? = nil,
        searchSessionIdFactory: SearchSessionIdFactory? = nil,
        client: URLSessionClient,
        store: ApolloStore
    ) {
        self.tokenFactory = tokenFactory
        self.sessionIdFactory = sessionIdFactory
        self.searchSessionIdFactory = searchSessionIdFactory
        super.init(client: client, shouldInvalidateClientOnDeinit: true, store: store)
    }

    override func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        var interceptors = super.interceptors(for: operation)
        interceptors.insert(CustomInterceptor(
            tokenFactory: tokenFactory,
            sessionIdFactory: sessionIdFactory,
            searchSessionIdFactory: searchSessionIdFactory
        ), at: 0)
        return interceptors
    }
}

private class CustomInterceptor: ApolloInterceptor {
    var id: String
    var tokenFactory: TokenFactory
    var sessionIdFactory: SessionIdFactory?
    var searchSessionIdFactory: SearchSessionIdFactory?

    init(
        tokenFactory: @escaping TokenFactory,
        sessionIdFactory: SessionIdFactory? = nil,
        searchSessionIdFactory: SearchSessionIdFactory? = nil
    ) {
        self.tokenFactory = tokenFactory
        self.sessionIdFactory = sessionIdFactory
        self.searchSessionIdFactory = searchSessionIdFactory
        self.id = "custom"
    }

    func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {

        Task {
            do {
                request.addHeader(name: "X-Application", value: "bccm-tvos")
                
                if let c = try await tokenFactory() {
                    request.addHeader(name: "Authorization", value: "Bearer " + c)
                }
                
                request.addHeader(name: "Accept-Language", value: Locale.current.identifier)
                
                if let sessionId = try await sessionIdFactory?() {
                    request.addHeader(name: "X-Session-ID", value: sessionId)
                }
                if let searchSessionId = try await searchSessionIdFactory?() {
                    request.addHeader(name: "X-Search-Session-ID", value: searchSessionId)
                }
                                
                chain.proceedAsync(request: request,
                        response: response,
                        interceptor: self,
                        completion: completion)
            } catch {
                print(error)
            }
        }
    }
}
