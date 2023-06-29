// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

extension API {
  class GetEpisodeStreamsQuery: GraphQLQuery {
    static let operationName: String = "GetEpisodeStreams"
    static let document: Apollo.DocumentType = .notPersisted(
      definition: .init(
        #"""
        query GetEpisodeStreams($id: ID!) {
          episode(id: $id) {
            __typename
            progress
            streams {
              __typename
              url
              type
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
        .field("episode", Episode.self, arguments: ["id": .variable("id")]),
      ] }

      var episode: Episode { __data["episode"] }

      /// Episode
      ///
      /// Parent Type: `Episode`
      struct Episode: API.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: Apollo.ParentType { API.Objects.Episode }
        static var __selections: [Apollo.Selection] { [
          .field("__typename", String.self),
          .field("progress", Int?.self),
          .field("streams", [Stream].self),
        ] }

        var progress: Int? { __data["progress"] }
        var streams: [Stream] { __data["streams"] }

        /// Episode.Stream
        ///
        /// Parent Type: `Stream`
        struct Stream: API.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: Apollo.ParentType { API.Objects.Stream }
          static var __selections: [Apollo.Selection] { [
            .field("__typename", String.self),
            .field("url", String.self),
            .field("type", GraphQLEnum<API.StreamType>.self),
          ] }

          var url: String { __data["url"] }
          var type: GraphQLEnum<API.StreamType> { __data["type"] }
        }
      }
    }
  }

}