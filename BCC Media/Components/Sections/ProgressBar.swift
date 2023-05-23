//
//  ProgressBar.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 15/05/2023.
//

import SwiftUI

struct ProgressBar: View {
    var item: Item

    func durationToString(_ duration: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .dropLeading

        return formatter.string(from: TimeInterval(duration))!
    }

    var body: some View {
        HStack(spacing: 2) {
            if let duration = item.duration {
                if let progress = item.progress {
                    ZStack {
                        GeometryReader { reader in
                            Color(uiColor: .black)
                                .frame(width: reader.size.width)
                                .opacity(0.5)
                            Color(uiColor: .white)
                                .frame(width: reader.size.width * CGFloat(Float(progress) / Float(duration)))
                                .cornerRadius(5)
                        }
                    }
                    .frame(height: 15)
                    .cornerRadius(5)
                } else {
                    Spacer()
                }
                Text(durationToString(duration)).font(.caption2).shadow(color: .black, radius: 2)
            }
        }.padding([.bottom, .horizontal], 10)
    }
}
