// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

public extension API {
  class GetPageQuery: GraphQLQuery {
    public static let operationName: String = "GetPage"
    public static let document: Apollo.DocumentType = .notPersisted(
      definition: .init(
        #"""
        query GetPage($id: ID!) {
          page(id: $id) {
            __typename
            id
            title
            description
            sections(first: 100) {
              __typename
              items {
                __typename
                id
                title
                description
                ...ItemSectionFragment
              }
            }
          }
        }
        """#,
        fragments: [ItemSectionFragment.self]
      ))

    public var id: ID

    public init(id: ID) {
      self.id = id
    }

    public var __variables: Variables? { ["id": id] }

    public struct Data: API.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: Apollo.ParentType { API.Objects.QueryRoot }
      public static var __selections: [Apollo.Selection] { [
        .field("page", Page.self, arguments: ["id": .variable("id")]),
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
          .field("id", API.ID.self),
          .field("title", String.self),
          .field("description", String?.self),
          .field("sections", Sections.self, arguments: ["first": 100]),
        ] }

        public var id: API.ID { __data["id"] }
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
              public init(data: DataDict) { __data = data }

              public static var __parentType: Apollo.ParentType { API.Interfaces.ItemSection }
              public static var __selections: [Apollo.Selection] { [
                .fragment(ItemSectionFragment.self),
              ] }

              public var id: API.ID { __data["id"] }
              public var title: String? { __data["title"] }
              public var description: String? { __data["description"] }
              public var items: ItemSectionFragment.Items { __data["items"] }

              public struct Fragments: FragmentContainer {
                public let __data: DataDict
                public init(data: DataDict) { __data = data }

                public var itemSectionFragment: ItemSectionFragment { _toFragment() }
              }
            }
          }
        }
      }
    }
  }

}