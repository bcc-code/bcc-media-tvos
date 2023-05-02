//
//  Languages.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 20/04/2023.
//

import Foundation

enum LanguageCodes: String, CaseIterable {
    case bg
    case da
    case de
    case en
    case es
    case fi
    case fr
    case hu
    case it
    case nb
    case nl
    case pl
    case pt
    case ro
    case ru
    case sl
    case tr
}

struct Language {
    var code: String
    var display: String
    var english: String?

    init(_ code: String, _ display: String) {
        self.code = code
        self.display = display
    }

    static func getAll() -> [Language] {
        var languages: [Language] = []

        let locale: Locale = .current
        let enLocale = Locale(identifier: "en")
        for code in LanguageCodes.allCases {
            let display = locale.localizedString(forLanguageCode: code.rawValue)
            var lang = Language(code.rawValue, display ?? code.rawValue)
            
            if lang.code == "nb" {
                lang.code = "no"
            }

            if let english = enLocale.localizedString(forLanguageCode: code.rawValue), english != display {
                lang.english = english
            }

            languages.append(lang)
        }

        return languages
    }

    private static var languageDict: [String: String] = [:]

    static func setLanguage(key: String, code: String) {
        UserDefaults.standard.set(code, forKey: "language:\(key)")
        languageDict[key] = code
    }

    static func getLanguage(key: String) -> String {
        if let lang = languageDict[key] {
            return lang
        }
        if let lang = UserDefaults.standard.string(forKey: "language:\(key)") {
            return lang
        }
        return Locale.current.identifier
    }
}
