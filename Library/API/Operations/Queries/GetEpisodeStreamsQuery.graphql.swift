// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

public extension API {
  class GetEpisodeStreamsQuery: GraphQLQuery {
    public static let operationName: String = "GetEpisodeStreams"
    public static let document: Apollo.DocumentType = .notPersisted(
      definition: .init(
        #"""
        query GetEpisodeStreams($id: ID!) {
          episode(id: $id) {
            __typename
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

    public struct Data: API.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: Apollo.ParentType { API.Objects.QueryRoot }
      public static var __selections: [Apollo.Selection] { [
        .field("episode", Episode.self, arguments: ["id": .variable("id")]),
      ] }

      public var episode: Episode { __data["episode"] }

      /// Episode
      ///
      /// Parent Type: `Episode`
      public struct Episode: API.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: Apollo.ParentType { API.Objects.Episode }
        public static var __selections: [Apollo.Selection] { [
          .field("__typename", String.self),
          .field("streams", [Stream].self),
        ] }

        public var streams: [Stream] { __data["streams"] }

        /// Episode.Stream
        ///
        /// Parent Type: `Stream`
        public struct Stream: API.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: Apollo.ParentType { API.Objects.Stream }
          public static var __selections: [Apollo.Selection] { [
            .field("__typename", String.self),
            .field("url", String.self),
            .field("type", GraphQLEnum<API.StreamType>.self),
          ] }

          public var url: String { __data["url"] }
          public var type: GraphQLEnum<API.StreamType> { __data["type"] }
        }
      }
    }
  }

}