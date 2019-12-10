//  Copyright © 2018 mkerekes. All rights reserved.

import XCTest
@testable import Domain
@testable import Presentation
@testable import Data
@testable import CoreTestHelpers

class BaseFeature: XCTestCase {
    
    lazy var app: XCUIApplication! = {
        return  XCUIApplication()
    }()
    lazy var configuration: TestAppConfiguration! = TestAppConfiguration(app: app, testCase: self)
    
    lazy var appSteps: AppSteps! = AppSteps(configuration: configuration)
    
//    lazy var factory = EntityFactory()
    lazy var featureFlags = FeatureFlags(uploadVideo: false, searchTabs: false, mention: false)
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        do {
            try configureEnvironmentLaunchArguments(for: app)
        } catch {
            guard let e = ServiceError(from: error)?.message else { return }
            fatalError(e)
        }
        app.launch()
    }
    
    override func tearDown() {
        app = nil
        super.tearDown()
    }
    
    lazy var requests = [String: [RequestResponsePair]]()
    var notification: [String: Any]?
//    lazy var user = factory.johnSmith()
    
    private func addInterruptionMonitor() {
        addUIInterruptionMonitor(withDescription: description) { element -> Bool in
            do {
                // Push Notification
                let button = element.buttons["Allow"]
                let title = element.staticTexts["“Demo App” Would Like to Send You Notifications"]
                if title.exists && button.exists {
                    button.tap()
                }
            }
            return true
        }
        app.tap()
    }
}

// MARK: Environment Launch Arguments
extension BaseFeature {
    
    /**
     This framework is built with a series of independent modules. These modules can accept
     data during instantiation and so may be pre-populated with data if desired.
     
     We utilise this trait within the UITests so that we can
     a) launch a module directly (rather than traversing a journey tree to arrive at the desired module)
     and
     b) launch a module with the test data for the conditions that we want to test.
     
     Use the launchEnvironment data to put in the
     - data that would represent the result of a network call (`responseDataResourceName`)
     - the identifier of the module that you want to launch directly (`moduleIdentifier`)
     
     Each subclass of this class (`BaseFeatureTestCase`) is required
     to override `fetchDataResourceName` & `moduleIdentifier`. It may optionally override (`responseDataResourceName`).
     Failure to override a required method will result in a `fatalError`
     */
    fileprivate func configureEnvironmentLaunchArguments(for app: XCUIApplication) throws {
        
        try requests.forEach({ (requestVariation) in
            let data = try JSONEncoder().encode(requestVariation.value)
            
            let encodedKey = requestVariation.key.replacingOccurrences(of: "=", with: "+")
            app.launchEnvironment[encodedKey] = data.base64EncodedString()
        })
        
        if let notification = notification {
            do {
                let data = try JSONSerialization.data(withJSONObject: notification)
                if let dataString = String(data: data, encoding: .utf8) {
                    app.launchEnvironment[UIApplication.LaunchOptionsKey.remoteNotification.rawValue] = dataString
                }
            } catch let error {
               print(error)
            }
        }
        
        app.launchEnvironment["isTesting"] = "true"
//        app.launchEnvironment["signedInUserID"] = user._id
        app.launchEnvironment["NoAnimations"] = "true"        
        app.launchEnvironment[FeatureFlags.mentionKey] = String(describing: featureFlags.mention)
        
    }
}

struct ProcessKeyConstants {
    static let moduleIdentifier = "moduleIdentifier"
    static let responseData = "responseData"
    static let requestData = "requestData"
}
