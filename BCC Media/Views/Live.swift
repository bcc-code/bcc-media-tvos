//
// Created by Fredrik Vedvik on 16/03/2023.
//

import AVKit
import Foundation
import SwiftUI

struct LiveResponse: Codable {
    var url: String

    enum CodingKeys: String, CodingKey {
        case url
    }
}

struct LivePlayer: View {
    @State var url: URL?
    
    func load() {
        Task {
            let token = await authenticationProvider.getAccessToken()
            if token != nil {
                var req = URLRequest(url: URL(string: "https://livestreamfunctions.brunstad.tv/api/urls/live")!)
                req.setValue("Bearer " + token!, forHTTPHeaderField: "Authorization")

                let (data, _) = try await URLSession.shared.data(for: req)
                let resp = try JSONDecoder().decode(LiveResponse.self, from: data)
                url = URL(string: resp.url)!
            }
        }
    }

    var body: some View {
        VStack {
            if let u = url {
                PlayerViewController(videoURL: u, title: NSLocalizedString("common_live", comment: ""), startFrom: 0).ignoresSafeArea()
            } else {
                ProgressView()
            }
        }.onAppear {
            load()
        }.ignoresSafeArea()
    }
}

extension LivePlayer: Hashable {
    static func == (lhs: LivePlayer, rhs: LivePlayer) -> Bool {
        true
    }
    
    func hash(into hasher: inout Hasher) {
        
    }
}

struct LiveView: View {
    var columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    @State var day: API.GetCalendarDayQuery.Data.Calendar.Day? = nil
    
    func getCalendaryDay() {
        apolloClient.fetch(query: API.GetCalendarDayQuery(day: toISOString(.now))) { result in
            switch result {
            case .success(let data):
                if let d = data.data?.calendar?.day {
                    day = d
                }
            case .failure:
                print("Failed")
            }
        }
    }
    
    func toISOString(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        
        formatter.timeZone = TimeZone.current
        
        return formatter.string(from: date)
    }
    
    func isoStringHours(_ str: String) -> String {
        let formatter = ISO8601DateFormatter()
        
        let date = formatter.date(from: str)!
        
        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: date)
        
        let hour = String(components.hour ?? 0).padding(toLength: 2, withPad: "0", startingAt: 0)
        let minute = String(components.minute ?? 0).padding(toLength: 2, withPad: "0", startingAt: 0)
        
        return "\(hour):\(minute)"
    }
    
    func isoStringDuration(_ start: String, _ end: String) -> String {
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
    
    enum Focusable: Hashable {
        case none
        case row(id: String)
    }
    
    @FocusState var focusState: Focusable?
    
    @FocusState var imageFocused
    
    @State var path: NavigationPath = .init()
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    Image(uiImage: UIImage(named: "Live.png")!)
                        .focusable()
                        .focused($imageFocused)
                        .scaleEffect(imageFocused ? 1.02 : 1)
                        .animation(.easeOut(duration: 0.1), value: imageFocused)
                        .onTapGesture {
                            path.append(LivePlayer())
                        }
                    VStack {
                        Text("common_live").font(.title).bold()
                    }
                    Spacer()
                }
                VStack(alignment: .leading) {
                    Text("calendar_today")
                    if let entries = day?.entries, entries.count > 0 {
                        ScrollView(.horizontal) {
                            LazyHStack(alignment: .top) {
                                ForEach(entries, id: \.self) {entry in
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
                                    .scaleEffect(focusState == .row(id: entry.id) ? 1.02 : 1)
                                    .animation(.easeOut(duration: 0.1), value: focusState == .row(id: entry.id))
                                    .focusable()
                                    .focused($focusState, equals: .row(id: entry.id))
                                }
                            }
                        }
                    } else {
                        HStack(alignment: .top) {
                            Text("calendar_noScheduledEvents").foregroundColor(.gray).bold()
                        }.padding(.top, 40)
                        Spacer()
                    }
                    Text("calendar_timetableInLocalTime")
                }
            }.navigationDestination(for: LivePlayer.self) { player in
                LivePlayer()
            }
        }
        .onAppear {
            getCalendaryDay()
        }
    }
}

struct LiveView_Previews: PreviewProvider {
    static var previews: some View {
        LiveView()
    }
}
