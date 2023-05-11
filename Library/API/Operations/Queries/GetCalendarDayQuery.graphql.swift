// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

public extension API {
  class GetCalendarDayQuery: GraphQLQuery {
    public static let operationName: String = "GetCalendarDay"
    public static let document: Apollo.DocumentType = .notPersisted(
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

    public struct Data: API.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: Apollo.ParentType { API.Objects.QueryRoot }
      public static var __selections: [Apollo.Selection] { [
        .field("calendar", Calendar?.self),
      ] }

      public var calendar: Calendar? { __data["calendar"] }

      /// Calendar
      ///
      /// Parent Type: `Calendar`
      public struct Calendar: API.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: Apollo.ParentType { API.Objects.Calendar }
        public static var __selections: [Apollo.Selection] { [
          .field("__typename", String.self),
          .field("day", Day.self, arguments: ["day": .variable("day")]),
        ] }

        public var day: Day { __data["day"] }

        /// Calendar.Day
        ///
        /// Parent Type: `CalendarDay`
        public struct Day: API.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: Apollo.ParentType { API.Objects.CalendarDay }
          public static var __selections: [Apollo.Selection] { [
            .field("__typename", String.self),
            .field("events", [Event].self),
            .field("entries", [Entry].self),
          ] }

          public var events: [Event] { __data["events"] }
          public var entries: [Entry] { __data["entries"] }

          /// Calendar.Day.Event
          ///
          /// Parent Type: `Event`
          public struct Event: API.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: Apollo.ParentType { API.Objects.Event }
            public static var __selections: [Apollo.Selection] { [
              .field("__typename", String.self),
              .field("title", String.self),
            ] }

            public var title: String { __data["title"] }
          }

          /// Calendar.Day.Entry
          ///
          /// Parent Type: `CalendarEntry`
          public struct Entry: API.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: Apollo.ParentType { API.Interfaces.CalendarEntry }
            public static var __selections: [Apollo.Selection] { [
              .field("__typename", String.self),
              .field("id", API.ID.self),
              .field("title", String.self),
              .field("start", API.Date.self),
              .field("end", API.Date.self),
              .field("description", String.self),
            ] }

            public var id: API.ID { __data["id"] }
            public var title: String { __data["title"] }
            public var start: API.Date { __data["start"] }
            public var end: API.Date { __data["end"] }
            public var description: String { __data["description"] }
          }
        }
      }
    }
  }

}