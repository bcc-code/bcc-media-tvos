// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetEpisodeSeasonQuery: GraphQLQuery {
  public static let operationName: String = "GetEpisodeSeason"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetEpisodeSeason($id: ID!) { season(id: $id) { __typename ...EpisodeSeason } }"#,
      fragments: [EpisodeSeason.self]
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
        .fragment(EpisodeSeason.self),
      ] }

      public var title: String { __data["title"] }
      public var show: Show { __data["show"] }
      public var episodes: Episodes { __data["episodes"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var episodeSeason: EpisodeSeason { _toFragment() }
      }

      public typealias Show = EpisodeSeason.Show

      public typealias Episodes = EpisodeSeason.Episodes
    }
  }
}
