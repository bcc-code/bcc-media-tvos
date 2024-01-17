import Foundation
import Apollo

internal class NetworkInterceptorProvider: DefaultInterceptorProvider {
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
    var id: String
    
    var tokenFactory: TokenFactory

    init(tokenFactory: @escaping TokenFactory) {
        self.tokenFactory = tokenFactory
        self.id = "custom"
    }

    func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {

        Task {
            do {
                request.addHeader(name: "X-Application", value: "live-tvos")
                
                if let c = try await tokenFactory() {
                    request.addHeader(name: "Authorization", value: "Bearer " + c)
                }
                
                request.addHeader(name: "Accept-Language", value: Locale.current.identifier)
                
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
