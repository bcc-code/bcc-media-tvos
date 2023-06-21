// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

extension API {
  class GetCalendarDayQuery: GraphQLQuery {
    static let operationName: String = "GetCalendarDay"
    static let document: Apollo.DocumentType = .notPersisted(
      definition: .init(
        #"""
        query GetCalendarDay($day: Date!) {
          calendar {
            __typename
            day(day: $day) {
              __typename
              events {
                __typename
                title
              }
              entries {
                __typename
                id
                title
                start
                end
                description
              }
            }
          }
        }
        """#
      ))

    public var day: Date

    public init(day: Date) {
      self.day = day
    }

    public var __variables: Variables? { ["day": day] }

    struct Data: API.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: Apollo.ParentType { API.Objects.QueryRoot }
      static var __selections: [Apollo.Selection] { [
        .field("calendar", Calendar?.self),
      ] }

      var calendar: Calendar? { __data["calendar"] }

      /// Calendar
      ///
      /// Parent Type: `Calendar`
      struct Calendar: API.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: Apollo.ParentType { API.Objects.Calendar }
        static var __selections: [Apollo.Selection] { [
          .field("__typename", String.self),
          .field("day", Day.self, arguments: ["day": .variable("day")]),
        ] }

        var day: Day { __data["day"] }

        /// Calendar.Day
        ///
        /// Parent Type: `CalendarDay`
        struct Day: API.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: Apollo.ParentType { API.Objects.CalendarDay }
          static var __selections: [Apollo.Selection] { [
            .field("__typename", String.self),
            .field("events", [Event].self),
            .field("entries", [Entry].self),
          ] }

          var events: [Event] { __data["events"] }
          var entries: [Entry] { __data["entries"] }

          /// Calendar.Day.Event
          ///
          /// Parent Type: `Event`
          struct Event: API.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: Apollo.ParentType { API.Objects.Event }
            static var __selections: [Apollo.Selection] { [
              .field("__typename", String.self),
              .field("title", String.self),
            ] }

            var title: String { __data["title"] }
          }

          /// Calendar.Day.Entry
          ///
          /// Parent Type: `CalendarEntry`
          struct Entry: API.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: Apollo.ParentType { API.Interfaces.CalendarEntry }
            static var __selections: [Apollo.Selection] { [
              .field("__typename", String.self),
              .field("id", API.ID.self),
              .field("title", String.self),
              .field("start", API.Date.self),
              .field("end", API.Date.self),
              .field("description", String.self),
            ] }

            var id: API.ID { __data["id"] }
            var title: String { __data["title"] }
            var start: API.Date { __data["start"] }
            var end: API.Date { __data["end"] }
            var description: String { __data["description"] }
          }
        }
      }
    }
  }

}