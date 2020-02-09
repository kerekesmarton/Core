//
//  Copyright © 2018 mkerekes. All rights reserved.
//

import Foundation
import Domain
import IosCore

class DependencyInjection {
    
    func injectDependencies(in container: ApplicationModules) {
        
        container.add(AppModule())
        
        // MARK: - Settings
        container.add(SettingsModule())
        
        //MARK: - Image handlers
        container.add(ImagePickerModule())
        container.add(ImageEditModule())
        container.add(ImageGalleryModule())
        container.add(MediaConvertingModule())
        
        container.add(TextModule())
    }
}
