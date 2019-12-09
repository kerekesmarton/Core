///
//  Core
//
//  Copyright © 2018 mkerekes. All rights reserved.
//

import Foundation

public class TenantDescription {
    public let name: String
    public let id: String?
    
    init(defaults: DefaultSettings, environment: Environment) {
        name = defaults.string(forKey: "CFBundleDisplayName")!
        id = nil
    }
    
    init(name: String, id: String?) {
        self.name = name
        self.id = id
    }
    
    static var standard: TenantDescription {
        let name = "Std"
        return TenantDescription(name: name, id: nil)
    }
}


