// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

public extension API {
  struct ItemSectionFragment: API.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString { """
      fragment ItemSectionFragment on ItemSection {
        __typename
        title
        items {
          __typename
          items {
            __typename
            id
            title
            description
            image
            item {
              __typename
              ... on Episode {
                progress
                duration
                locked
              }
            }
          }
        }
      }
      """ }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: Apollo.ParentType { API.Interfaces.ItemSection }
    public static var __selections: [Apollo.Selection] { [
      .field("__typename", String.self),
      .field("title", String?.self),
      .field("items", Items.self),
    ] }

    public var title: String? { __data["title"] }
    public var items: Items { __data["items"] }

    /// Items
    ///
    /// Parent Type: `SectionItemPagination`
    public struct Items: API.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: Apollo.ParentType { API.Objects.SectionItemPagination }
      public static var __selections: [Apollo.Selection] { [
        .field("__typename", String.self),
        .field("items", [Item].self),
      ] }

      public var items: [Item] { __data["items"] }

      /// Items.Item
      ///
      /// Parent Type: `SectionItem`
      public struct Item: API.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: Apollo.ParentType { API.Objects.SectionItem }
        public static var __selections: [Apollo.Selection] { [
          .field("__typename", String.self),
          .field("id", API.ID.self),
          .field("title", String.self),
          .field("description", String.self),
          .field("image", String?.self),
          .field("item", Item.self),
        ] }

        public var id: API.ID { __data["id"] }
        public var title: String { __data["title"] }
        public var description: String { __data["description"] }
        public var image: String? { __data["image"] }
        public var item: Item { __data["item"] }

        /// Items.Item.Item
        ///
        /// Parent Type: `SectionItemType`
        public struct Item: API.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: Apollo.ParentType { API.Unions.SectionItemType }
          public static var __selections: [Apollo.Selection] { [
            .field("__typename", String.self),
            .inlineFragment(AsEpisode.self),
          ] }

          public var asEpisode: AsEpisode? { _asInlineFragment() }

          /// Items.Item.Item.AsEpisode
          ///
          /// Parent Type: `Episode`
          public struct AsEpisode: API.InlineFragment {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public typealias RootEntityType = ItemSectionFragment.Items.Item.Item
            public static var __parentType: Apollo.ParentType { API.Objects.Episode }
            public static var __selections: [Apollo.Selection] { [
              .field("progress", Int?.self),
              .field("duration", Int.self),
              .field("locked", Bool.self),
            ] }

            public var progress: Int? { __data["progress"] }
            public var duration: Int { __data["duration"] }
            public var locked: Bool { __data["locked"] }
          }
        }
      }
    }
  }

}