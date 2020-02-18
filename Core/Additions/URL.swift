//
//  URL.swift
//  Additions
//
//  Created by Marton Kerekes on 18/02/2020.
//  Copyright © 2020 Marton Kerekes. All rights reserved.
//

import Foundation

public extension URL {
    func stringRemoving(params: [String]) -> String? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        params.forEach { (param) in
            components?.queryItems?.removeAll(where: { (item) -> Bool in
                return item.name == param
            })
        }
        guard var reducedURL = components?.url?.absoluteString else {
            return nil
        }
        if reducedURL.last == "?" {
            reducedURL.removeLast()
        }
        return reducedURL
    }
}
