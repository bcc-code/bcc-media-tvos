// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct EpisodeSeason: API.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment EpisodeSeason on Season { __typename title show { __typename title description seasons(first: 100) { __typename items { __typename id title } } } episodes(first: 100) { __typename items { __typename id title description image } } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { API.Objects.Season }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("title", String.self),
    .field("show", Show.self),
    .field("episodes", Episodes.self, arguments: ["first": 100]),
  ] }

  public var title: String { __data["title"] }
  public var show: Show { __data["show"] }
  public var episodes: Episodes { __data["episodes"] }

  /// Show
  ///
  /// Parent Type: `Show`
  public struct Show: API.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { API.Objects.Show }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("title", String.self),
      .field("description", String.self),
      .field("seasons", Seasons.self, arguments: ["first": 100]),
    ] }

    public var title: String { __data["title"] }
    public var description: String { __data["description"] }
    public var seasons: Seasons { __data["seasons"] }

    /// Show.Seasons
    ///
    /// Parent Type: `SeasonPagination`
    public struct Seasons: API.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { API.Objects.SeasonPagination }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("items", [Item].self),
      ] }

      public var items: [Item] { __data["items"] }

      /// Show.Seasons.Item
      ///
      /// Parent Type: `Season`
      public struct Item: API.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { API.Objects.Season }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", API.ID.self),
          .field("title", String.self),
        ] }

        public var id: API.ID { __data["id"] }
        public var title: String { __data["title"] }
      }
    }
  }

  /// Episodes
  ///
  /// Parent Type: `EpisodePagination`
  public struct Episodes: API.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { API.Objects.EpisodePagination }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("items", [Item].self),
    ] }

    public var items: [Item] { __data["items"] }

    /// Episodes.Item
    ///
    /// Parent Type: `Episode`
    public struct Item: API.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { API.Objects.Episode }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
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
