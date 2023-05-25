//
//  CalendarDay.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 19/05/2023.
//

import SwiftUI

private func toISOString(_ date: Date) -> String {
    let formatter = ISO8601DateFormatter()

    formatter.timeZone = TimeZone.current

    return formatter.string(from: date)
}

private func isoStringHours(_ str: String) -> String {
    let formatter = ISO8601DateFormatter()

    let date = formatter.date(from: str)!

    let components = Calendar.current.dateComponents([.day, .hour, .minute], from: date)

    let hour = String(components.hour ?? 0).padding(toLength: 2, withPad: "0", startingAt: 0)
    let minute = String(components.minute ?? 0).padding(toLength: 2, withPad: "0", startingAt: 0)

    return "\(hour):\(minute)"
}

private func isoStringDuration(_ start: String, _ end: String) -> String {
    let formatter = ISO8601DateFormatter()

    let startDate = formatter.date(from: start)!
    let endDate = formatter.date(from: end)!

    let components = Calendar.current.dateComponents([.day, .hour, .minute], from: startDate, to: endDate)

    var str = ""

    if let hour = components.hour, hour > 0 {
        str += String(hour) + "h"
    }

    if let minute = components.minute, minute > 0 {
        if str != "" {
            str += " "
        }
        str += String(minute) + "m"
    }

    return str
}

struct CalendarDay: View {
    @State var day: API.GetCalendarDayQuery.Data.Calendar.Day? = nil

    func getCalendarDay() async {
        let data = await apolloClient.getAsync(query: API.GetCalendarDayQuery(day: toISOString(.now)))
        if let calendar = data?.calendar {
            day = calendar.day
        }
    }

    enum Focusable: Hashable {
        case none
        case row(id: String)
    }

    @FocusState var focusState: Focusable?

    var body: some View {
        VStack(alignment: .leading) {
            Text("calendar_today")
            if let entries = day?.entries, entries.count > 0 {
                ScrollView(.horizontal) {
                    LazyHStack(alignment: .top) {
                        ForEach(entries, id: \.self) { entry in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(isoStringHours(entry.start)).bold()
                                    Text(isoStringDuration(entry.start, entry.end)).foregroundColor(.gray)
                                }
                                VStack(alignment: .leading) {
                                    Text(entry.title).bold()
                                    Text(entry.description).foregroundColor(.blue)
                                }
                            }
                            .padding(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.white, lineWidth: focusState == .row(id: entry.id) ? 6 : 0)
                            )
                            .cornerRadius(10)
                            .scaleEffect(focusState == .row(id: entry.id) ? 1.02 : 1)
                            .animation(.easeOut(duration: 0.1), value: focusState == .row(id: entry.id))
                            .focusable()
                            .focused($focusState, equals: .row(id: entry.id))
                        }
                    }
                }
                Text("calendar_timetableInLocalTime")
            } else {
                HStack(alignment: .top) {
                    Text("calendar_noScheduledEvents").foregroundColor(.gray).bold()
                }.padding(.top, 40)
                Spacer()
            }
        }.task {
            await getCalendarDay()
        }
    }
}
