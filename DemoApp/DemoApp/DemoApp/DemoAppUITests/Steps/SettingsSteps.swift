///
//
//  Copyright © 2018 mkerekes. All rights reserved.
//

import Foundation
import XCTest
@testable import Domain

class SettingsSteps: BaseSteps {

    lazy var settingsScreen: BaseScreen = BaseScreen(configuration: configuration)
    
    func titleMatches( string: String) {
        settingsScreen.waitToExist(for: settingsScreen.title(named: string))
    }
    
    func goTo(settings: Settings) {
        var page: String
        switch settings {
        case .external:
            page = "App Settings"
        }
        settingsScreen.waitToTap(element: settingsScreen.firstCell(of: .staticText, named: page))
    }
    
}
