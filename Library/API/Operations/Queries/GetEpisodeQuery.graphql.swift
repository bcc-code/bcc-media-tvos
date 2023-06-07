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
            ...BaseEpisode
            next {
              __typename
              ...BaseEpisode
            }
          }
        }
        """#,
        fragments: [BaseEpisode.self]
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
          .field("next", [Next].self),
          .fragment(BaseEpisode.self),
        ] }

        /// Should probably be used asynchronously, and retrieved separately from the episode, as it can be slow in some cases (a few db requests can occur)
        public var next: [Next] { __data["next"] }
        public var id: API.ID { __data["id"] }
        public var type: GraphQLEnum<API.EpisodeType> { __data["type"] }
        public var title: String { __data["title"] }
        public var image: String? { __data["image"] }
        public var ageRating: String { __data["ageRating"] }
        public var publishDate: API.Date { __data["publishDate"] }
        public var description: String { __data["description"] }
        public var progress: Int? { __data["progress"] }
        public var locked: Bool { __data["locked"] }
        public var season: BaseEpisode.Season? { __data["season"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var baseEpisode: BaseEpisode { _toFragment() }
        }

        /// Episode.Next
        ///
        /// Parent Type: `Episode`
        public struct Next: API.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: Apollo.ParentType { API.Objects.Episode }
          public static var __selections: [Apollo.Selection] { [
            .field("__typename", String.self),
            .fragment(BaseEpisode.self),
          ] }

          public var id: API.ID { __data["id"] }
          public var type: GraphQLEnum<API.EpisodeType> { __data["type"] }
          public var title: String { __data["title"] }
          public var image: String? { __data["image"] }
          public var ageRating: String { __data["ageRating"] }
          public var publishDate: API.Date { __data["publishDate"] }
          public var description: String { __data["description"] }
          public var progress: Int? { __data["progress"] }
          public var locked: Bool { __data["locked"] }
          public var season: BaseEpisode.Season? { __data["season"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var baseEpisode: BaseEpisode { _toFragment() }
          }
        }
      }
    }
  }

}