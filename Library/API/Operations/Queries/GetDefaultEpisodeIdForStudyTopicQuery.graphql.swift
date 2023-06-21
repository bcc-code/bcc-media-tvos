// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

extension API {
  class GetDefaultEpisodeIdForStudyTopicQuery: GraphQLQuery {
    static let operationName: String = "GetDefaultEpisodeIdForStudyTopic"
    static let document: Apollo.DocumentType = .notPersisted(
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

    struct Data: API.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: Apollo.ParentType { API.Objects.QueryRoot }
      static var __selections: [Apollo.Selection] { [
        .field("studyTopic", StudyTopic.self, arguments: ["id": .variable("id")]),
      ] }

      var studyTopic: StudyTopic { __data["studyTopic"] }

      /// StudyTopic
      ///
      /// Parent Type: `StudyTopic`
      struct StudyTopic: API.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: Apollo.ParentType { API.Objects.StudyTopic }
        static var __selections: [Apollo.Selection] { [
          .field("__typename", String.self),
          .field("defaultLesson", DefaultLesson.self),
        ] }

        /// The default lesson.
        /// Should not be used actively in lists, as it could affect query speeds.
        var defaultLesson: DefaultLesson { __data["defaultLesson"] }

        /// StudyTopic.DefaultLesson
        ///
        /// Parent Type: `Lesson`
        struct DefaultLesson: API.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: Apollo.ParentType { API.Objects.Lesson }
          static var __selections: [Apollo.Selection] { [
            .field("__typename", String.self),
            .field("defaultEpisode", DefaultEpisode?.self),
          ] }

          /// The default episode.
          /// Should not be used actively in lists, as it could affect query speeds.
          var defaultEpisode: DefaultEpisode? { __data["defaultEpisode"] }

          /// StudyTopic.DefaultLesson.DefaultEpisode
          ///
          /// Parent Type: `Episode`
          struct DefaultEpisode: API.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: Apollo.ParentType { API.Objects.Episode }
            static var __selections: [Apollo.Selection] { [
              .field("__typename", String.self),
              .field("id", API.ID.self),
            ] }

            var id: API.ID { __data["id"] }
          }
        }
      }
    }
  }

}