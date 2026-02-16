//
//  WordBundleLoader.swift
//  PalabraDD
//
//  Created by Developer on 11/1/25.
//

import Foundation

enum WordLoadError: Error {
    case fileNotFound
}

final class WordBundleLoader {
    static func load(fileName: String) throws -> [WordEntry] {
        let bundle = Bundle.moduleIfAvailable ?? Bundle.main
        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            throw WordLoadError.fileNotFound
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode([WordEntry].self, from: data)
    }
}

// Helper so this works whether code is in app target or (later) a Swift Package
private extension Bundle {
    static var moduleIfAvailable: Bundle? {
        #if SWIFT_PACKAGE
        return .module
        #else
        return nil
        #endif
    }
}
