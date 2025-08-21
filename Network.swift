import Foundation
import ApolloWebSocket
import Network
import Apollo
import ApolloAPI

class Network {
    static let shared = Network()
    
    private(set) lazy var apollo: ApolloClient = {
        let store = ApolloStore()
        
        // --- START OF NEW CONFIGURATION ---
        
        // 1. Create a session configuration that uses the shared, persistent cookie storage.
        let configuration = URLSessionConfiguration.default
        configuration.httpCookieStorage = HTTPCookieStorage.shared
        
        // 2. Create a URLSessionClient that uses our custom configuration.
        let client = URLSessionClient(sessionConfiguration: configuration)
        let provider = DefaultInterceptorProvider(client: client, store: store)

        // --- END OF NEW CONFIGURATION ---

        // 3. The rest of the setup is the same, but uses our new provider.
        let httpTransport = RequestChainNetworkTransport(
            interceptorProvider: provider,
            endpointURL: URL(string: "https://starsbackend.onrender.com/graphql/")!
        )
        
        let webSocketTransport = WebSocketTransport(
            websocket: WebSocket(
                url: URL(string: "wss://starsbackend.onrender.com/graphql/")!,
                protocol: .graphql_ws
            )
        )
        
        let splitTransport = SplitNetworkTransport(
            uploadingNetworkTransport: httpTransport,
            webSocketNetworkTransport: webSocketTransport
        )
        
        return ApolloClient(networkTransport: splitTransport, store: store)
    }()
    
    private init() {}
}
