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

struct EntryView: View {
    var entry: API.GetCalendarDayQuery.Data.Calendar.Day.Entry

    init(_ entry: API.GetCalendarDayQuery.Data.Calendar.Day.Entry) {
        self.entry = entry
    }

    @FocusState var focused

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(isoStringHours(entry.start)).bold()
                Text(isoStringDuration(entry.start, entry.end)).font(.caption2).foregroundColor(.gray)
            }
            VStack(alignment: .leading) {
                Text(entry.title).bold()
                Text(entry.description).font(.caption2).foregroundColor(.blue)
            }
        }
        .padding(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.white, lineWidth: focused ? 6 : 0)
        )
        .cornerRadius(10)
        .scaleEffect(focused ? 1.02 : 1)
        .animation(.easeOut(duration: 0.1), value: focused)
        .focusable()
        .focused($focused)
    }
}

struct CalendarDay: View {
    var horizontal = true

    @State var day: API.GetCalendarDayQuery.Data.Calendar.Day? = nil

    func getCalendarDay() async {
        let data = await apolloClient.getAsync(query: API.GetCalendarDayQuery(day: "2023-05-28T00:00:00Z"))
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
                if horizontal {
                    ScrollView(.horizontal) {
                        LazyHStack(alignment: .top, spacing: 20) {
                            ForEach(entries, id: \.self) { entry in
                                EntryView(entry)
                            }
                        }.padding(20)
                    }.padding(-20).padding(.vertical, 5)
                } else {
                    ScrollView(.vertical) {
                        LazyVStack(alignment: .center, spacing: 5) {
                            ForEach(entries, id: \.self) { entry in
                                EntryView(entry)
                            }
                        }.padding(20)
                    }.padding(-20).padding(.vertical, 5)
                }
                Spacer()
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
