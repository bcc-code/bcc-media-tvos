// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

public extension API {
  class GetPageQuery: GraphQLQuery {
    public static let operationName: String = "GetPage"
    public static let document: Apollo.DocumentType = .notPersisted(
      definition: .init(
        #"""
        query GetPage {
          page(code: "frontpage") {
            __typename
            title
            description
            sections(first: 100) {
              __typename
              items {
                __typename
                id
                ... on ItemSection {
                  title
                  items {
                    __typename
                    items {
                      __typename
                      id
                      title
                      image
                    }
                  }
                }
              }
            }
          }
        }
        """#
      ))

    public init() {}

    public struct Data: API.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: Apollo.ParentType { API.Objects.QueryRoot }
      public static var __selections: [Apollo.Selection] { [
        .field("page", Page.self, arguments: ["code": "frontpage"]),
      ] }

      public var page: Page { __data["page"] }

      /// Page
      ///
      /// Parent Type: `Page`
      public struct Page: API.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: Apollo.ParentType { API.Objects.Page }
        public static var __selections: [Apollo.Selection] { [
          .field("title", String.self),
          .field("description", String?.self),
          .field("sections", Sections.self, arguments: ["first": 100]),
        ] }

        public var title: String { __data["title"] }
        public var description: String? { __data["description"] }
        public var sections: Sections { __data["sections"] }

        /// Page.Sections
        ///
        /// Parent Type: `SectionPagination`
        public struct Sections: API.SelectionSet {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: Apollo.ParentType { API.Objects.SectionPagination }
          public static var __selections: [Apollo.Selection] { [
            .field("items", [Item].self),
          ] }

          public var items: [Item] { __data["items"] }

          /// Page.Sections.Item
          ///
          /// Parent Type: `Section`
          public struct Item: API.SelectionSet {
            public let __data: DataDict
            public init(data: DataDict) { __data = data }

            public static var __parentType: Apollo.ParentType { API.Interfaces.Section }
            public static var __selections: [Apollo.Selection] { [
              .field("id", API.ID.self),
              .inlineFragment(AsItemSection.self),
            ] }

            public var id: API.ID { __data["id"] }

            public var asItemSection: AsItemSection? { _asInlineFragment() }

            /// Page.Sections.Item.AsItemSection
            ///
            /// Parent Type: `ItemSection`
            public struct AsItemSection: API.InlineFragment {
              public let __data: DataDict
              public init(data: DataDict) { __data = data }

              public static var __parentType: Apollo.ParentType { API.Interfaces.ItemSection }
              public static var __selections: [Apollo.Selection] { [
                .field("title", String?.self),
                .field("items", Items.self),
              ] }

              public var title: String? { __data["title"] }
              public var items: Items { __data["items"] }
              public var id: API.ID { __data["id"] }

              /// Page.Sections.Item.AsItemSection.Items
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

                /// Page.Sections.Item.AsItemSection.Items.Item
                ///
                /// Parent Type: `SectionItem`
                public struct Item: API.SelectionSet {
                  public let __data: DataDict
                  public init(data: DataDict) { __data = data }

                  public static var __parentType: Apollo.ParentType { API.Objects.SectionItem }
                  public static var __selections: [Apollo.Selection] { [
                    .field("id", API.ID.self),
                    .field("title", String.self),
                    .field("image", String?.self),
                  ] }

                  public var id: API.ID { __data["id"] }
                  public var title: String { __data["title"] }
                  public var image: String? { __data["image"] }
                }
              }
            }
          }
        }
      }
    }
  }

}