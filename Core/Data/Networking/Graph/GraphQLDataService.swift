///
//  Core
//
//  Copyright © 2019 Connectt. All rights reserved.
//

import Foundation
import Additions
import Domain
import Apollo

class GraphQLDataService {
    
    var userStore: UserProfileStoring
    let dataPersistence: DataPersisting?
    var dispatcher: Dispatching = Dispatcher()
    
    init(userStore: UserProfileStoring,
        dataPersistence: DataPersisting?){
        
        self.userStore = userStore
        self.dataPersistence = dataPersistence
    }
    
    // Configure the network transport to use the singleton as the delegate.
    private lazy var networkTransport = HTTPNetworkTransport(
      url: URL(string: "http://localhost:8080/graphql")!,
      delegate: self
    )
      
    // Use the configured network transport in your Apollo client.
    private(set) lazy var apollo = ApolloClient(networkTransport: self.networkTransport)

    
    
    
    
}

// MARK: - Pre-flight delegate

extension GraphQLDataService: HTTPNetworkTransportPreflightDelegate {

  func networkTransport(_ networkTransport: HTTPNetworkTransport,
                          shouldSend request: URLRequest) -> Bool {
    // If there's an authenticated user, send the request. If not, don't.
    
    guard userStore.token != nil else { return false }
    return true
  }
  
  func networkTransport(_ networkTransport: HTTPNetworkTransport,
                        willSend request: inout URLRequest) {
          
    guard let token = userStore.token else { return }
    // Get the existing headers, or create new ones if they're nil
      var headers = request.allHTTPHeaderFields ?? [String: String]()

      // Add any new headers you need
    headers["Authorization"] = "Bearer \(token)"
    
      // Re-assign the updated headers to the request.
      request.allHTTPHeaderFields = headers
  }
}

// MARK: - Task Completed Delegate

extension GraphQLDataService: HTTPNetworkTransportTaskCompletedDelegate {
  func networkTransport(_ networkTransport: HTTPNetworkTransport,
                        didCompleteRawTaskForRequest request: URLRequest,
                        withData data: Data?,
                        response: URLResponse?,
                        error: Error?) {
    
    print(request.description)
    print(response?.description ?? "")
  }
}
