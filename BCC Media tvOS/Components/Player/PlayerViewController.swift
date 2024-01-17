//
//  PlayerViewController.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 04/05/2023.
//

import AVKit
import SwiftUI
import NpawPlugin

struct PlaybackState {
    var time: Double
}

private let npawAccountCode = ProcessInfo.processInfo.environment["NPAW_ACCOUNT_CODE"] ?? CI.npawAccountCode

extension NpawPluginProvider {
    static func setup() {
        self.initialize(accountCode: npawAccountCode, logLevel: .info)
    }
}
