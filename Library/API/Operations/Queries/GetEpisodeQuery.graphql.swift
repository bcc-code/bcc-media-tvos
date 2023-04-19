// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

public extension API {
  class GetEpisodeQuery: GraphQLQuery {
    public static let operationName: String = "GetEpisode"
    public static let document: Apollo.DocumentType = .notPersisted(
      definition: .init(
        #"""
        query GetEpisode($id: ID!) {
          episode(id: $id) {
            __typename
            title
            image
            description
            streams {
              __typename
              url
              type
            }
            season {
              __typename
              title
              show {
                __typename
                title
              }
              episodes(first: 100) {
                __typename
                items {
                  __typename
                  id
                  title
                  description
                  image
                }
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
      public init(data: DataDict) { __data = data }

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
        public init(data: DataDict) { __data = data }

        public static var __parentType: Apollo.ParentType { API.Objects.Episode }
        public static var __selections: [Apollo.Selection] { [
          .field("title", String.self),
          .field("image", String?.self),
          .field("description", String.self),
          .field("streams", [Stream].self),
          .field("season", Season?.self),
        ] }

        public var title: String { __data["title"] }
        public var image: String? { __data["image"] }
        public var description: String { __data["description"] }
        public var streams: [Stream] { __data["streams"] }
        public var season: Season? { __data["season"] }

        /// Episode.Stream
        ///
        /// Parent Type: `Stream`
        public struct Stream: API.SelectionSet {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: Apollo.ParentType { API.Objects.Stream }
          public static var __selections: [Apollo.Selection] { [
            .field("url", String.self),
            .field("type", GraphQLEnum<API.StreamType>.self),
          ] }

          public var url: String { __data["url"] }
          public var type: GraphQLEnum<API.StreamType> { __data["type"] }
        }

        /// Episode.Season
        ///
        /// Parent Type: `Season`
        public struct Season: API.SelectionSet {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: Apollo.ParentType { API.Objects.Season }
          public static var __selections: [Apollo.Selection] { [
            .field("title", String.self),
            .field("show", Show.self),
            .field("episodes", Episodes.self, arguments: ["first": 100]),
          ] }

          public var title: String { __data["title"] }
          public var show: Show { __data["show"] }
          public var episodes: Episodes { __data["episodes"] }

          /// Episode.Season.Show
          ///
          /// Parent Type: `Show`
          public struct Show: API.SelectionSet {
            public let __data: DataDict
            public init(data: DataDict) { __data = data }

            public static var __parentType: Apollo.ParentType { API.Objects.Show }
            public static var __selections: [Apollo.Selection] { [
              .field("title", String.self),
            ] }

            public var title: String { __data["title"] }
          }

          /// Episode.Season.Episodes
          ///
          /// Parent Type: `EpisodePagination`
          public struct Episodes: API.SelectionSet {
            public let __data: DataDict
            public init(data: DataDict) { __data = data }

            public static var __parentType: Apollo.ParentType { API.Objects.EpisodePagination }
            public static var __selections: [Apollo.Selection] { [
              .field("items", [Item].self),
            ] }

            public var items: [Item] { __data["items"] }

            /// Episode.Season.Episodes.Item
            ///
            /// Parent Type: `Episode`
            public struct Item: API.SelectionSet {
              public let __data: DataDict
              public init(data: DataDict) { __data = data }

              public static var __parentType: Apollo.ParentType { API.Objects.Episode }
              public static var __selections: [Apollo.Selection] { [
                .field("id", API.ID.self),
                .field("title", String.self),
                .field("description", String.self),
                .field("image", String?.self),
              ] }

              public var id: API.ID { __data["id"] }
              public var title: String { __data["title"] }
              public var description: String { __data["description"] }
              public var image: String? { __data["image"] }
            }
          }
        }
      }
    }
  }

}