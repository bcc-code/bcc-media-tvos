// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

extension API {
  class GetFirstEpisodeInPlaylistQuery: GraphQLQuery {
    static let operationName: String = "GetFirstEpisodeInPlaylist"
    static let operationDocument: Apollo.OperationDocument = .init(
      definition: .init(
        #"query GetFirstEpisodeInPlaylist($id: ID!) { playlist(id: $id) { __typename items(first: 1) { __typename items { __typename id } } } }"#
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
        .field("playlist", Playlist.self, arguments: ["id": .variable("id")]),
      ] }

      var playlist: Playlist { __data["playlist"] }

      /// Playlist
      ///
      /// Parent Type: `Playlist`
      struct Playlist: API.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: Apollo.ParentType { API.Objects.Playlist }
        static var __selections: [Apollo.Selection] { [
          .field("__typename", String.self),
          .field("items", Items.self, arguments: ["first": 1]),
        ] }

        var items: Items { __data["items"] }

        /// Playlist.Items
        ///
        /// Parent Type: `PlaylistItemPagination`
        struct Items: API.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: Apollo.ParentType { API.Objects.PlaylistItemPagination }
          static var __selections: [Apollo.Selection] { [
            .field("__typename", String.self),
            .field("items", [Item].self),
          ] }

          var items: [Item] { __data["items"] }

          /// Playlist.Items.Item
          ///
          /// Parent Type: `PlaylistItem`
          struct Item: API.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: Apollo.ParentType { API.Interfaces.PlaylistItem }
            static var __selections: [Apollo.Selection] { [
              .field("__typename", String.self),
              .field("id", API.ID.self),
            ] }

            var id: API.ID { __data["id"] }
          }
        }
      }
    }
  }

}