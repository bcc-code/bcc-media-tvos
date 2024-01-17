// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetDefaultEpisodeIdForShowQuery: GraphQLQuery {
  public static let operationName: String = "GetDefaultEpisodeIdForShow"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetDefaultEpisodeIdForShow($id: ID!) { show(id: $id) { __typename defaultEpisode { __typename id } } }"#
    ))

  public var id: ID

  public init(id: ID) {
    self.id = id
  }

  public var __variables: Variables? { ["id": id] }

  public struct Data: API.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { API.Objects.QueryRoot }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("show", Show.self, arguments: ["id": .variable("id")]),
    ] }

    public var show: Show { __data["show"] }

    /// Show
    ///
    /// Parent Type: `Show`
    public struct Show: API.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { API.Objects.Show }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("defaultEpisode", DefaultEpisode.self),
      ] }

      /// The default episode.
      /// Should not be used actively in lists, as it could affect query speeds.
      public var defaultEpisode: DefaultEpisode { __data["defaultEpisode"] }

      /// Show.DefaultEpisode
      ///
      /// Parent Type: `Episode`
      public struct DefaultEpisode: API.SelectionSet {
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
