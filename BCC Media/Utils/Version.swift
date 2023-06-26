//
//  Version.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 26/06/2023.
//

import Foundation

func getVersion() -> String {
    let versionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    let buildString = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""

    return "\(versionString) (\(buildString))"
}
