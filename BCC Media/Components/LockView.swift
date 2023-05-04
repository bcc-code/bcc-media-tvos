//
//  LockView.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 04/05/2023.
//

import SwiftUI

struct LockView: View {
    var locked = false

    var body: some View {
        if locked {
            ZStack {
                Color.black.opacity(0.5)
                Image(systemName: "lock.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
        }
    }
}
