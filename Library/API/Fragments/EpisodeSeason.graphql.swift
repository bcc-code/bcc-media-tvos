// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

extension API {
  struct EpisodeSeason: API.SelectionSet, Fragment {
    static var fragmentDefinition: StaticString {
      #"fragment EpisodeSeason on Season { __typename title show { __typename title description seasons(first: 100) { __typename items { __typename id title } } } episodes(first: 100) { __typename items { __typename id title description image } } }"#
    }

    let __data: DataDict
    init(_dataDict: DataDict) { __data = _dataDict }

    static var __parentType: Apollo.ParentType { API.Objects.Season }
    static var __selections: [Apollo.Selection] { [
      .field("__typename", String.self),
      .field("title", String.self),
      .field("show", Show.self),
      .field("episodes", Episodes.self, arguments: ["first": 100]),
    ] }

    var title: String { __data["title"] }
    var show: Show { __data["show"] }
    var episodes: Episodes { __data["episodes"] }

    /// Show
    ///
    /// Parent Type: `Show`
    struct Show: API.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: Apollo.ParentType { API.Objects.Show }
      static var __selections: [Apollo.Selection] { [
        .field("__typename", String.self),
        .field("title", String.self),
        .field("description", String.self),
        .field("seasons", Seasons.self, arguments: ["first": 100]),
      ] }

      var title: String { __data["title"] }
      var description: String { __data["description"] }
      var seasons: Seasons { __data["seasons"] }

      /// Show.Seasons
      ///
      /// Parent Type: `SeasonPagination`
      struct Seasons: API.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: Apollo.ParentType { API.Objects.SeasonPagination }
        static var __selections: [Apollo.Selection] { [
          .field("__typename", String.self),
          .field("items", [Item].self),
        ] }

        var items: [Item] { __data["items"] }

        /// Show.Seasons.Item
        ///
        /// Parent Type: `Season`
        struct Item: API.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: Apollo.ParentType { API.Objects.Season }
          static var __selections: [Apollo.Selection] { [
            .field("__typename", String.self),
            .field("id", API.ID.self),
            .field("title", String.self),
          ] }

          var id: API.ID { __data["id"] }
          var title: String { __data["title"] }
        }
      }
    }

    /// Episodes
    ///
    /// Parent Type: `EpisodePagination`
    struct Episodes: API.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: Apollo.ParentType { API.Objects.EpisodePagination }
      static var __selections: [Apollo.Selection] { [
        .field("__typename", String.self),
        .field("items", [Item].self),
      ] }

      var items: [Item] { __data["items"] }

      /// Episodes.Item
      ///
      /// Parent Type: `Episode`
      struct Item: API.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: Apollo.ParentType { API.Objects.Episode }
        static var __selections: [Apollo.Selection] { [
          .field("__typename", String.self),
          .field("id", API.ID.self),
          .field("title", String.self),
          .field("description", String.self),
          .field("image", String?.self),
        ] }

        var id: API.ID { __data["id"] }
        var title: String { __data["title"] }
        var description: String { __data["description"] }
        var image: String? { __data["image"] }
      }
    }
  }

}