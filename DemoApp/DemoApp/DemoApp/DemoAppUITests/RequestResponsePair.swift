///

//
//  Copyright © 2018 mkerekes. All rights reserved.
//

import Foundation
@testable import Data
@testable import Domain

class RequestResponsePair: Codable {
    var request: String? = nil
    var response: String? = nil
    
    init<Request, Response>(request: Request, response: Response) throws {
        guard let requestData = try GenericDataEncoder().encode(from: request) else {
            throw ServiceError.parsing("couldn't parse data \(request)")
        }
        
        guard let responseData = try GenericDataEncoder().encode(from: response) else {
            throw ServiceError.parsing("couldn't parse data \(response)")
        }
        
        self.request = requestData.base64EncodedString()
        self.response = responseData.base64EncodedString()
    }
    
    init<Response>(response: Response) throws {
        
        guard let responseData = try GenericDataEncoder().encode(from: response) else {
            throw ServiceError.parsing("couldn't parse data \(response)")
        }
        
        self.response = responseData.base64EncodedString()
    }
    
    init() {}
}
