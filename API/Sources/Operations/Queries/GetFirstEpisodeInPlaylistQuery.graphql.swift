// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetFirstEpisodeInPlaylistQuery: GraphQLQuery {
  public static let operationName: String = "GetFirstEpisodeInPlaylist"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetFirstEpisodeInPlaylist($id: ID!) { playlist(id: $id) { __typename items(first: 1) { __typename items { __typename id } } } }"#
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
      .field("playlist", Playlist.self, arguments: ["id": .variable("id")]),
    ] }

    public var playlist: Playlist { __data["playlist"] }

    /// Playlist
    ///
    /// Parent Type: `Playlist`
    public struct Playlist: API.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { API.Objects.Playlist }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("items", Items.self, arguments: ["first": 1]),
      ] }

      public var items: Items { __data["items"] }

      /// Playlist.Items
      ///
      /// Parent Type: `PlaylistItemPagination`
      public struct Items: API.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { API.Objects.PlaylistItemPagination }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("items", [Item].self),
        ] }

        public var items: [Item] { __data["items"] }

        /// Playlist.Items.Item
        ///
        /// Parent Type: `PlaylistItem`
        public struct Item: API.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { API.Interfaces.PlaylistItem }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", API.ID.self),
          ] }

          public var id: API.ID { __data["id"] }
        }
      }
    }
  }
}
