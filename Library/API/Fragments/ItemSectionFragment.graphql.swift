// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

extension API {
  struct ItemSectionFragment: API.SelectionSet, Fragment {
    static var fragmentDefinition: StaticString {
      #"fragment ItemSectionFragment on ItemSection { __typename title metadata { __typename prependLiveElement useContext collectionId } items { __typename items { __typename id title description image item { __typename ... on Episode { progress duration locked } } } } }"#
    }

    let __data: DataDict
    init(_dataDict: DataDict) { __data = _dataDict }

    static var __parentType: Apollo.ParentType { API.Interfaces.ItemSection }
    static var __selections: [Apollo.Selection] { [
      .field("__typename", String.self),
      .field("title", String?.self),
      .field("metadata", Metadata?.self),
      .field("items", Items.self),
    ] }

    var title: String? { __data["title"] }
    var metadata: Metadata? { __data["metadata"] }
    var items: Items { __data["items"] }

    /// Metadata
    ///
    /// Parent Type: `ItemSectionMetadata`
    struct Metadata: API.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: Apollo.ParentType { API.Objects.ItemSectionMetadata }
      static var __selections: [Apollo.Selection] { [
        .field("__typename", String.self),
        .field("prependLiveElement", Bool.self),
        .field("useContext", Bool.self),
        .field("collectionId", API.ID.self),
      ] }

      var prependLiveElement: Bool { __data["prependLiveElement"] }
      var useContext: Bool { __data["useContext"] }
      var collectionId: API.ID { __data["collectionId"] }
    }

    /// Items
    ///
    /// Parent Type: `SectionItemPagination`
    struct Items: API.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: Apollo.ParentType { API.Objects.SectionItemPagination }
      static var __selections: [Apollo.Selection] { [
        .field("__typename", String.self),
        .field("items", [Item].self),
      ] }

      var items: [Item] { __data["items"] }

      /// Items.Item
      ///
      /// Parent Type: `SectionItem`
      struct Item: API.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: Apollo.ParentType { API.Objects.SectionItem }
        static var __selections: [Apollo.Selection] { [
          .field("__typename", String.self),
          .field("id", API.ID.self),
          .field("title", String.self),
          .field("description", String.self),
          .field("image", String?.self),
          .field("item", Item.self),
        ] }

        var id: API.ID { __data["id"] }
        var title: String { __data["title"] }
        var description: String { __data["description"] }
        var image: String? { __data["image"] }
        var item: Item { __data["item"] }

        /// Items.Item.Item
        ///
        /// Parent Type: `SectionItemType`
        struct Item: API.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: Apollo.ParentType { API.Unions.SectionItemType }
          static var __selections: [Apollo.Selection] { [
            .field("__typename", String.self),
            .inlineFragment(AsEpisode.self),
          ] }

          var asEpisode: AsEpisode? { _asInlineFragment() }

          /// Items.Item.Item.AsEpisode
          ///
          /// Parent Type: `Episode`
          struct AsEpisode: API.InlineFragment {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            typealias RootEntityType = ItemSectionFragment.Items.Item.Item
            static var __parentType: Apollo.ParentType { API.Objects.Episode }
            static var __selections: [Apollo.Selection] { [
              .field("progress", Int?.self),
              .field("duration", Int.self),
              .field("locked", Bool.self),
            ] }

            var progress: Int? { __data["progress"] }
            var duration: Int { __data["duration"] }
            var locked: Bool { __data["locked"] }
          }
        }
      }
    }
  }

}