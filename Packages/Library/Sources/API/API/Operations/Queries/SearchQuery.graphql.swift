// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension API {
  class SearchQuery: GraphQLQuery {
    public static let operationName: String = "Search"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        query Search($query: String!, $collection: String!) {
          search(queryString: $query, type: $collection) {
            __typename
            result {
              __typename
              id
              title
              description
              image
              highlight
              url
            }
          }
        }
        """#
      ))

    public var query: String
    public var collection: String

    public init(
      query: String,
      collection: String
    ) {
      self.query = query
      self.collection = collection
    }

    public var __variables: Variables? { [
      "query": query,
      "collection": collection
    ] }

    public struct Data: API.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { API.Objects.QueryRoot }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("search", Search.self, arguments: [
          "queryString": .variable("query"),
          "type": .variable("collection")
        ]),
      ] }

      public var search: Search { __data["search"] }

      /// Search
      ///
      /// Parent Type: `SearchResult`
      public struct Search: API.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { API.Objects.SearchResult }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("result", [Result].self),
        ] }

        public var result: [Result] { __data["result"] }

        /// Search.Result
        ///
        /// Parent Type: `SearchResultItem`
        public struct Result: API.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { API.Interfaces.SearchResultItem }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", API.ID.self),
            .field("title", String.self),
            .field("description", String?.self),
            .field("image", String?.self),
            .field("highlight", String?.self),
            .field("url", String.self),
          ] }

          public var id: API.ID { __data["id"] }
          public var title: String { __data["title"] }
          public var description: String? { __data["description"] }
          public var image: String? { __data["image"] }
          public var highlight: String? { __data["highlight"] }
          public var url: String { __data["url"] }
        }
      }
    }
  }

}