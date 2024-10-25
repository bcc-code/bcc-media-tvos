//
//  Languages.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 20/04/2023.
//

import Foundation

enum LanguageCodes: String, CaseIterable {
    case nb
    case en
    case bg
    case da
    case de
    case es
    case fi
    case fr
    case hu
    case it
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
    
    static func toThreeLetterLanguageCode(languageCode: String?) -> String? {
        return switch languageCode {
        case "no":
            "nor"
        case "en":
            "eng"
        case "fr":
            "fra"
        case "de":
            "deu"
        case "hu":
            "hun"
        case "es":
            "spa"
        case "it":
            "ita"
        case "pl":
            "pol"
        case "ro":
            "ron"
        case "ru":
            "rus"
        case "sl":
            "slv"
        case "tr":
            "tur"
        case "bg":
            "bul"
        case "nl":
            "nld"
        case "da":
            "dan"
        case "fi":
            "fin"
        case "pt":
            "por"
        default:
            languageCode
        }
    }
}
