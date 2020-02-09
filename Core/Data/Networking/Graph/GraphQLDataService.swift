///
//  Core
//
//  Copyright © 2019 Connectt. All rights reserved.
//

import Foundation
import Additions
import Domain
import Apollo

class GraphQLDataService: SpecialisedDataService {
    
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

    
    func getData<T>(from: URL, completion: @escaping (T?, ServiceError?) -> Void) {
        
    }
    
    func getData<T>(from: URL, parameters: [String : String], completion: @escaping (T?, ServiceError?) -> Void) {
        
    }
    
    func getData<T>(parameters: [String], completion: @escaping (T?, ServiceError?) -> Void) {
        
    }
    
    func getData<T>(parameters: [String : String], completion: @escaping (T?, ServiceError?) -> Void) {
        
    }
    
    func getData<T, U>(payload: U?, completion: @escaping (T?, ServiceError?) -> Void) {
        
    }
    
    func getData<T, U>(parameters: [String], payload: U?, completion: @escaping (T?, ServiceError?) -> Void) {
        
    }
    
    func getData<T, U>(parameters: [String : String], payload: U?, completion: @escaping (T?, ServiceError?) -> Void) {
        
    }
    
    func upload<T, U>(data: Data, parameters: [String : String], payload: U, completion: @escaping (T?, ServiceError?) -> Void) {
        
    }
    
    func subscribeToCache<T>(changes: @escaping (T?, ServiceError?) -> Void) {
        
    }
    
    func subscribeToCache<T>(with parameters: [String : String], changes: @escaping (T?, ServiceError?) -> Void) {
        
    }
    
    func fetchCache<T>(parameters: [String : String], update: @escaping (T?, ServiceError?) -> Void) {
        
    }
    
    func fetchCacheList<T>(parameters: [String : String], update: @escaping (T?, ServiceError?) -> Void) {
        
    }
    
    func saveCache<T>(payload: T, parameters: [String : String], completion: @escaping (ServiceError?) -> Void) {
        
    }
    
    func deleteCache(completion: @escaping (ServiceError?) -> Void) {
        
    }
    
    func getData<T>(fetchResult: @escaping (T?, ServiceError?) -> Void) {
        
    }
    
    
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
    
    print(request)
    print(response)
  }
}
