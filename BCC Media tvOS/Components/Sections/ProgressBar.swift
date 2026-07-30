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

        return formatter.string(from: TimeInterval(duration)) ?? ""
    }

    var body: some View {
        HStack(spacing: 2) {
            if let duration = item.duration {
                // `duration > 0` guards a division by zero: the fraction became NaN, and a NaN frame
                // width is a SwiftUI layout error. Clamped as well, so progress past the end — which the
                // API does return — cannot overflow the bar.
                if let progress = item.progress, duration > 0 {
                    let fraction = min(max(Double(progress) / Double(duration), 0), 1)
                    ZStack {
                        GeometryReader { reader in
                            Color(uiColor: .black)
                                .frame(width: reader.size.width)
                                .opacity(0.5)
                            Color(uiColor: .white)
                                .frame(width: reader.size.width * fraction)
                                .cornerRadius(5)
                        }
                    }
                    .frame(height: 15)
                    .cornerRadius(5)
                } else {
                    Spacer()
                }
                Text(durationToString(duration)).font(.barlowCaption).shadow(color: .black, radius: 2)
            }
        }.padding([.bottom, .horizontal], 10)
    }
}
