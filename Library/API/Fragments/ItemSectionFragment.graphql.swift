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
          }
        }
      }
      """ }

    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: Apollo.ParentType { API.Interfaces.ItemSection }
    public static var __selections: [Apollo.Selection] { [
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
      public init(data: DataDict) { __data = data }

      public static var __parentType: Apollo.ParentType { API.Objects.SectionItemPagination }
      public static var __selections: [Apollo.Selection] { [
        .field("items", [Item].self),
      ] }

      public var items: [Item] { __data["items"] }

      /// Items.Item
      ///
      /// Parent Type: `SectionItem`
      public struct Item: API.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: Apollo.ParentType { API.Objects.SectionItem }
        public static var __selections: [Apollo.Selection] { [
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

}