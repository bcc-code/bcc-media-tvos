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

    /// The API and the stream manifests identify Norwegian as `no`, but `nb` is the code Foundation
    /// localizes a display name from. Load-bearing: `nb` derives the alpha-3 code `nob`, where the
    /// backend and NPAW both expect `nor`.
    private static let norwegianApiCode = "no"

    static func getAll() -> [Language] {
        var languages: [Language] = []

        let locale: Locale = .current
        let enLocale = Locale(identifier: "en")
        for code in LanguageCodes.allCases {
            let display = locale.localizedString(forLanguageCode: code.rawValue)
            var lang = Language(code.rawValue, display ?? code.rawValue)

            if code == .nb {
                lang.code = norwegianApiCode
            }

            if let english = enLocale.localizedString(forLanguageCode: code.rawValue), english != display {
                lang.english = english
            }

            languages.append(lang)
        }

        return languages
    }
    
    /// Replaces a hand-maintained 17-entry table, which every new entry in ``LanguageCodes`` had to be
    /// added to or would silently fall through to its two-letter form. Verified to derive the same
    /// value for all 17 codes the table covered.
    ///
    /// Only ever called with codes produced by ``getAll()``, where `nb` has already become `no` — see
    /// ``norwegianApiCode``.
    static func toThreeLetterLanguageCode(languageCode: String?) -> String? {
        guard let languageCode = languageCode else {
            return nil
        }
        // Unknown codes keep their input form, as the table's `default` did.
        return Locale.Language(identifier: languageCode).languageCode?.identifier(.alpha3) ?? languageCode
    }
}
