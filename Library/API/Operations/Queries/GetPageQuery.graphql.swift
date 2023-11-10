// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

extension API {
  class GetPageQuery: GraphQLQuery {
    static let operationName: String = "GetPage"
    static let operationDocument: Apollo.OperationDocument = .init(
      definition: .init(
        #"query GetPage($id: ID!) { page(id: $id) { __typename id code title description sections(first: 100) { __typename items { __typename id title description ...ItemSectionFragment } } } }"#,
        fragments: [ItemSectionFragment.self]
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
        .field("page", Page.self, arguments: ["id": .variable("id")]),
      ] }

      var page: Page { __data["page"] }

      /// Page
      ///
      /// Parent Type: `Page`
      struct Page: API.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: Apollo.ParentType { API.Objects.Page }
        static var __selections: [Apollo.Selection] { [
          .field("__typename", String.self),
          .field("id", API.ID.self),
          .field("code", String.self),
          .field("title", String.self),
          .field("description", String?.self),
          .field("sections", Sections.self, arguments: ["first": 100]),
        ] }

        var id: API.ID { __data["id"] }
        var code: String { __data["code"] }
        var title: String { __data["title"] }
        var description: String? { __data["description"] }
        var sections: Sections { __data["sections"] }

        /// Page.Sections
        ///
        /// Parent Type: `SectionPagination`
        struct Sections: API.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: Apollo.ParentType { API.Objects.SectionPagination }
          static var __selections: [Apollo.Selection] { [
            .field("__typename", String.self),
            .field("items", [Item].self),
          ] }

          var items: [Item] { __data["items"] }

          /// Page.Sections.Item
          ///
          /// Parent Type: `Section`
          struct Item: API.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: Apollo.ParentType { API.Interfaces.Section }
            static var __selections: [Apollo.Selection] { [
              .field("__typename", String.self),
              .field("id", API.ID.self),
              .field("title", String?.self),
              .field("description", String?.self),
              .inlineFragment(AsItemSection.self),
            ] }

            var id: API.ID { __data["id"] }
            var title: String? { __data["title"] }
            var description: String? { __data["description"] }

            var asItemSection: AsItemSection? { _asInlineFragment() }

            /// Page.Sections.Item.AsItemSection
            ///
            /// Parent Type: `ItemSection`
            struct AsItemSection: API.InlineFragment {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              typealias RootEntityType = GetPageQuery.Data.Page.Sections.Item
              static var __parentType: Apollo.ParentType { API.Interfaces.ItemSection }
              static var __selections: [Apollo.Selection] { [
                .fragment(ItemSectionFragment.self),
              ] }

              var id: API.ID { __data["id"] }
              var title: String? { __data["title"] }
              var description: String? { __data["description"] }
              var metadata: ItemSectionFragment.Metadata? { __data["metadata"] }
              var items: ItemSectionFragment.Items { __data["items"] }

              struct Fragments: FragmentContainer {
                let __data: DataDict
                init(_dataDict: DataDict) { __data = _dataDict }

                var itemSectionFragment: ItemSectionFragment { _toFragment() }
              }
            }
          }
        }
      }
    }
  }

}