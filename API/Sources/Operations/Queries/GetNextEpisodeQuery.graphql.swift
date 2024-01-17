// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetNextEpisodeQuery: GraphQLQuery {
  public static let operationName: String = "GetNextEpisode"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetNextEpisode($id: ID!, $context: EpisodeContext!) { episode(id: $id, context: $context) { __typename id cursor next { __typename id } } }"#
    ))

  public var id: ID
  public var context: EpisodeContext

  public init(
    id: ID,
    context: EpisodeContext
  ) {
    self.id = id
    self.context = context
  }

  public var __variables: Variables? { [
    "id": id,
    "context": context
  ] }

  public struct Data: API.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { API.Objects.QueryRoot }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("episode", Episode.self, arguments: [
        "id": .variable("id"),
        "context": .variable("context")
      ]),
    ] }

    public var episode: Episode { __data["episode"] }

    /// Episode
    ///
    /// Parent Type: `Episode`
    public struct Episode: API.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { API.Objects.Episode }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", API.ID.self),
        .field("cursor", String.self),
        .field("next", [Next].self),
      ] }

      public var id: API.ID { __data["id"] }
      public var cursor: String { __data["cursor"] }
      /// Should probably be used asynchronously, and retrieved separately from the episode, as it can be slow in some cases (a few db requests can occur)
      public var next: [Next] { __data["next"] }

      /// Episode.Next
      ///
      /// Parent Type: `Episode`
      public struct Next: API.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { API.Objects.Episode }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", API.ID.self),
        ] }

        public var id: API.ID { __data["id"] }
      }
    }
  }
}
