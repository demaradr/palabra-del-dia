//
//  LanguageCatalog.swift
//  PalabraDD
//
//  Created by Developer on 11/1/25.
//

import Foundation

struct LanguageOption: Identifiable, Hashable {
    let id: String
    let sourceLanguage: String
    let targetLanguage: String
    let label: String
    let fileName: String
}

enum LanguageCatalog {
    static let options: [LanguageOption] = [
        LanguageOption(id: "es-en", sourceLanguage: "es-ES", targetLanguage: "en-US", label: "Spanish → English", fileName: "words_es_en"),
        LanguageOption(id: "en-es", sourceLanguage: "en-US", targetLanguage: "es-ES", label: "English → Spanish", fileName: "words_en_es"),
        LanguageOption(id: "de-en", sourceLanguage: "de-DE", targetLanguage: "en-US", label: "German → English", fileName: "words_de_en"),
        LanguageOption(id: "it-en", sourceLanguage: "it-IT", targetLanguage: "en-US", label: "Italian → English", fileName: "words_it_en")
    ]

    static let defaultID = "es-en"

    static func option(for id: String?) -> LanguageOption {
        guard let id, let match = options.first(where: { $0.id == id }) else {
            return options[0]
        }
        return match
    }
}
