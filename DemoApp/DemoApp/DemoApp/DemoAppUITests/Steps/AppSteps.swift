//

//
//  Copyright © 2018 mkerekes. All rights reserved.
//

import XCTest

class AppSteps: BaseSteps {
    
    var appScreen: BaseScreen {
        return screen.baseScreen
    }
    
    var app: XCUIApplication {
        return appScreen.app
    }
    
    // MARK: - Tabs
    enum Tab: Int {
        case feed
        case explore
        case createPost
        case notifications
        case profile
    }
    
    func goTo(tab: Tab) {
        let button = appScreen.tabBarItem(tab: tab)
        appScreen.waitToBeHittable(for: button)
        button.tap()
    }
    
    // MARK: - Notifications
    func verifyPushNotification(message: String) {
        let label = app.staticTexts[message]
        appScreen.waitToExist(for: label)
    }
    
    func tapNotificationAndWaitToBeDismissed(with title: String) {
        let label = app.staticTexts[title]
        label.tap()
        appScreen.waitToNotExist(for: label)
    }
    
    func waitForNotificationToBeDismissed(with title: String) {
        let label = app.staticTexts[title]
        appScreen.waitToNotExist(for: label)
    }
    
    func tapOutsideNotificationAndWaitToBeDismissed(with title: String) {
        app.tap()
        let label = app.staticTexts[title]
        appScreen.waitToNotExist(for: label)
    }
}
