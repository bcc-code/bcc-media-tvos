//
//  PlayerListener.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 22/06/2023.
//

import Foundation


class PlayerListener {
    var stateCallback: (PlaybackState) -> Void
    var endCallback: () -> Void
    var expireCallback: () -> Void

    init(stateCallback: @escaping (PlaybackState) -> Void = { _ in }, endCallback: @escaping () -> Void = {}, expireCallback: @escaping () -> Void = {}) {
        self.stateCallback = stateCallback
        self.endCallback = endCallback
        self.expireCallback = expireCallback
    }

    func onStateUpdate(state: PlaybackState) {
        stateCallback(state)
    }

    func onEnd() {
        endCallback()
    }
    
    func onExpire() {
        expireCallback()
    }

    @objc func playerDidFinishPlaying(note _: NSNotification) {
        onEnd()
    }
}
