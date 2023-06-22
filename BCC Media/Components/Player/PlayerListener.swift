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

    init(stateCallback: @escaping (PlaybackState) -> Void, endCallback: @escaping () -> Void = {}) {
        self.stateCallback = stateCallback
        self.endCallback = endCallback
    }

    func onStateUpdate(state: PlaybackState) {
        stateCallback(state)
    }

    func onEnd() {
        endCallback()
    }

    @objc func playerDidFinishPlaying(note _: NSNotification) {
        onEnd()
    }
}
