// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetPageQuery: GraphQLQuery {
  public static let operationName: String = "GetPage"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetPage($id: ID!) { page(id: $id) { __typename id code title description sections(first: 100) { __typename items { __typename id title description ...ItemSectionFragment } } } }"#,
      fragments: [ItemSectionFragment.self]
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
      .field("page", Page.self, arguments: ["id": .variable("id")]),
    ] }

    public var page: Page { __data["page"] }

    /// Page
    ///
    /// Parent Type: `Page`
    public struct Page: API.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { API.Objects.Page }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", API.ID.self),
        .field("code", String.self),
        .field("title", String.self),
        .field("description", String?.self),
        .field("sections", Sections.self, arguments: ["first": 100]),
      ] }

      public var id: API.ID { __data["id"] }
      public var code: String { __data["code"] }
      public var title: String { __data["title"] }
      public var description: String? { __data["description"] }
      public var sections: Sections { __data["sections"] }

      /// Page.Sections
      ///
      /// Parent Type: `SectionPagination`
      public struct Sections: API.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { API.Objects.SectionPagination }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("items", [Item].self),
        ] }

        public var items: [Item] { __data["items"] }

        /// Page.Sections.Item
        ///
        /// Parent Type: `Section`
        public struct Item: API.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { API.Interfaces.Section }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", API.ID.self),
            .field("title", String?.self),
            .field("description", String?.self),
            .inlineFragment(AsItemSection.self),
          ] }

          public var id: API.ID { __data["id"] }
          public var title: String? { __data["title"] }
          public var description: String? { __data["description"] }

          public var asItemSection: AsItemSection? { _asInlineFragment() }

          /// Page.Sections.Item.AsItemSection
          ///
          /// Parent Type: `ItemSection`
          public struct AsItemSection: API.InlineFragment {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public typealias RootEntityType = GetPageQuery.Data.Page.Sections.Item
            public static var __parentType: ApolloAPI.ParentType { API.Interfaces.ItemSection }
            public static var __selections: [ApolloAPI.Selection] { [
              .fragment(ItemSectionFragment.self),
            ] }

            public var id: API.ID { __data["id"] }
            public var title: String? { __data["title"] }
            public var description: String? { __data["description"] }
            public var metadata: Metadata? { __data["metadata"] }
            public var items: Items { __data["items"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var itemSectionFragment: ItemSectionFragment { _toFragment() }
            }

            public typealias Metadata = ItemSectionFragment.Metadata

            public typealias Items = ItemSectionFragment.Items
          }
        }
      }
    }
  }
}
