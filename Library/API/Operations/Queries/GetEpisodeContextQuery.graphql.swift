// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

public extension API {
  class GetEpisodeContextQuery: GraphQLQuery {
    public static let operationName: String = "GetEpisodeContext"
    public static let document: Apollo.DocumentType = .notPersisted(
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

    public struct Data: API.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: Apollo.ParentType { API.Objects.QueryRoot }
      public static var __selections: [Apollo.Selection] { [
        .field("episode", Episode.self, arguments: [
          "id": .variable("id"),
          "context": .variable("context")
        ]),
      ] }

      public var episode: Episode { __data["episode"] }

      /// Episode
      ///
      /// Parent Type: `Episode`
      public struct Episode: API.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: Apollo.ParentType { API.Objects.Episode }
        public static var __selections: [Apollo.Selection] { [
          .field("__typename", String.self),
          .field("context", Context?.self),
        ] }

        public var context: Context? { __data["context"] }

        /// Episode.Context
        ///
        /// Parent Type: `EpisodeContextUnion`
        public struct Context: API.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: Apollo.ParentType { API.Unions.EpisodeContextUnion }
          public static var __selections: [Apollo.Selection] { [
            .field("__typename", String.self),
            .inlineFragment(AsContextCollection.self),
          ] }

          public var asContextCollection: AsContextCollection? { _asInlineFragment() }

          /// Episode.Context.AsContextCollection
          ///
          /// Parent Type: `ContextCollection`
          public struct AsContextCollection: API.InlineFragment {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public typealias RootEntityType = GetEpisodeContextQuery.Data.Episode.Context
            public static var __parentType: Apollo.ParentType { API.Objects.ContextCollection }
            public static var __selections: [Apollo.Selection] { [
              .field("items", Items?.self, arguments: ["first": 100]),
            ] }

            public var items: Items? { __data["items"] }

            /// Episode.Context.AsContextCollection.Items
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

              /// Episode.Context.AsContextCollection.Items.Item
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
                ] }

                public var id: API.ID { __data["id"] }
                public var title: String { __data["title"] }
                public var description: String { __data["description"] }
                public var image: String? { __data["image"] }
              }
            }
          }
        }
      }
    }
  }

}