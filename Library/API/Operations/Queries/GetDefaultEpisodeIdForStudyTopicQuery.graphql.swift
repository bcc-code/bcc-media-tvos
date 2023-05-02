// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

public extension API {
  class GetDefaultEpisodeIdForStudyTopicQuery: GraphQLQuery {
    public static let operationName: String = "GetDefaultEpisodeIdForStudyTopic"
    public static let document: Apollo.DocumentType = .notPersisted(
      definition: .init(
        #"""
        query GetDefaultEpisodeIdForStudyTopic($id: ID!) {
          studyTopic(id: $id) {
            __typename
            defaultLesson {
              __typename
              defaultEpisode {
                __typename
                id
              }
            }
          }
        }
        """#
      ))

    public var id: ID

    public init(id: ID) {
      self.id = id
    }

    public var __variables: Variables? { ["id": id] }

    public struct Data: API.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: Apollo.ParentType { API.Objects.QueryRoot }
      public static var __selections: [Apollo.Selection] { [
        .field("studyTopic", StudyTopic.self, arguments: ["id": .variable("id")]),
      ] }

      public var studyTopic: StudyTopic { __data["studyTopic"] }

      /// StudyTopic
      ///
      /// Parent Type: `StudyTopic`
      public struct StudyTopic: API.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: Apollo.ParentType { API.Objects.StudyTopic }
        public static var __selections: [Apollo.Selection] { [
          .field("__typename", String.self),
          .field("defaultLesson", DefaultLesson.self),
        ] }

        /// The default lesson.
        /// Should not be used actively in lists, as it could affect query speeds.
        public var defaultLesson: DefaultLesson { __data["defaultLesson"] }

        /// StudyTopic.DefaultLesson
        ///
        /// Parent Type: `Lesson`
        public struct DefaultLesson: API.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: Apollo.ParentType { API.Objects.Lesson }
          public static var __selections: [Apollo.Selection] { [
            .field("__typename", String.self),
            .field("defaultEpisode", DefaultEpisode?.self),
          ] }

          /// The default episode.
          /// Should not be used actively in lists, as it could affect query speeds.
          public var defaultEpisode: DefaultEpisode? { __data["defaultEpisode"] }

          /// StudyTopic.DefaultLesson.DefaultEpisode
          ///
          /// Parent Type: `Episode`
          public struct DefaultEpisode: API.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: Apollo.ParentType { API.Objects.Episode }
            public static var __selections: [Apollo.Selection] { [
              .field("__typename", String.self),
              .field("id", API.ID.self),
            ] }

            public var id: API.ID { __data["id"] }
          }
        }
      }
    }
  }

}