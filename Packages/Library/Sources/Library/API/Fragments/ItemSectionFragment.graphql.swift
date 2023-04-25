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
              ... on Show {
                defaultEpisode {
                  __typename
                  id
                }
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
            .inlineFragment(AsShow.self),
          ] }

          public var asShow: AsShow? { _asInlineFragment() }

          /// Items.Item.Item.AsShow
          ///
          /// Parent Type: `Show`
          public struct AsShow: API.InlineFragment {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public typealias RootEntityType = ItemSectionFragment.Items.Item.Item
            public static var __parentType: Apollo.ParentType { API.Objects.Show }
            public static var __selections: [Apollo.Selection] { [
              .field("defaultEpisode", DefaultEpisode.self),
            ] }

            public var defaultEpisode: DefaultEpisode { __data["defaultEpisode"] }

            /// Items.Item.Item.AsShow.DefaultEpisode
            ///
            /// Parent Type: `Episode`
            public struct DefaultEpisode: API.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: Apollo.ParentType { API.Objects.Episode }
              public static var __selections: [Apollo.Selection] { [
                .field("__typename", String.self),
                .field("id", API.ID.self),
              ] }

              public var id: API.ID { __data["id"] }
            }
          }
        }
      }
    }
  }

}