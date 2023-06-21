// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

extension API {
  class GetEpisodeContextQuery: GraphQLQuery {
    static let operationName: String = "GetEpisodeContext"
    static let document: Apollo.DocumentType = .notPersisted(
      definition: .init(
        #"""
        query GetEpisodeContext($id: ID!, $context: EpisodeContext) {
          episode(id: $id, context: $context) {
            __typename
            context {
              __typename
              ... on ContextCollection {
                items(first: 100) {
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
            }
          }
        }
        """#
      ))

    public var id: ID
    public var context: GraphQLNullable<EpisodeContext>

    public init(
      id: ID,
      context: GraphQLNullable<EpisodeContext>
    ) {
      self.id = id
      self.context = context
    }

    public var __variables: Variables? { [
      "id": id,
      "context": context
    ] }

    struct Data: API.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: Apollo.ParentType { API.Objects.QueryRoot }
      static var __selections: [Apollo.Selection] { [
        .field("episode", Episode.self, arguments: [
          "id": .variable("id"),
          "context": .variable("context")
        ]),
      ] }

      var episode: Episode { __data["episode"] }

      /// Episode
      ///
      /// Parent Type: `Episode`
      struct Episode: API.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: Apollo.ParentType { API.Objects.Episode }
        static var __selections: [Apollo.Selection] { [
          .field("__typename", String.self),
          .field("context", Context?.self),
        ] }

        var context: Context? { __data["context"] }

        /// Episode.Context
        ///
        /// Parent Type: `EpisodeContextUnion`
        struct Context: API.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: Apollo.ParentType { API.Unions.EpisodeContextUnion }
          static var __selections: [Apollo.Selection] { [
            .field("__typename", String.self),
            .inlineFragment(AsContextCollection.self),
          ] }

          var asContextCollection: AsContextCollection? { _asInlineFragment() }

          /// Episode.Context.AsContextCollection
          ///
          /// Parent Type: `ContextCollection`
          struct AsContextCollection: API.InlineFragment {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            typealias RootEntityType = GetEpisodeContextQuery.Data.Episode.Context
            static var __parentType: Apollo.ParentType { API.Objects.ContextCollection }
            static var __selections: [Apollo.Selection] { [
              .field("items", Items?.self, arguments: ["first": 100]),
            ] }

            var items: Items? { __data["items"] }

            /// Episode.Context.AsContextCollection.Items
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

              /// Episode.Context.AsContextCollection.Items.Item
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
                ] }

                var id: API.ID { __data["id"] }
                var title: String { __data["title"] }
                var description: String { __data["description"] }
                var image: String? { __data["image"] }
              }
            }
          }
        }
      }
    }
  }

}