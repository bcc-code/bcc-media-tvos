// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetDefaultEpisodeIdForSeasonQuery: GraphQLQuery {
  public static let operationName: String = "GetDefaultEpisodeIdForSeason"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetDefaultEpisodeIdForSeason($id: ID!) { season(id: $id) { __typename defaultEpisode { __typename id } } }"#
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
      .field("season", Season.self, arguments: ["id": .variable("id")]),
    ] }

    public var season: Season { __data["season"] }

    /// Season
    ///
    /// Parent Type: `Season`
    public struct Season: API.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { API.Objects.Season }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("defaultEpisode", DefaultEpisode.self),
      ] }

      /// The default episode.
      /// Should not be used actively in lists, as it could affect query speeds.
      public var defaultEpisode: DefaultEpisode { __data["defaultEpisode"] }

      /// Season.DefaultEpisode
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
