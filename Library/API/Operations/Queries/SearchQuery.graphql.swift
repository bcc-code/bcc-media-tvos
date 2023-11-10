// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

extension API {
  class SearchQuery: GraphQLQuery {
    static let operationName: String = "Search"
    static let operationDocument: Apollo.OperationDocument = .init(
      definition: .init(
        #"query Search($query: String!, $collection: String!) { search(queryString: $query, type: $collection) { __typename result { __typename id title description image highlight url } } }"#
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

    struct Data: API.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: Apollo.ParentType { API.Objects.QueryRoot }
      static var __selections: [Apollo.Selection] { [
        .field("search", Search.self, arguments: [
          "queryString": .variable("query"),
          "type": .variable("collection")
        ]),
      ] }

      var search: Search { __data["search"] }

      /// Search
      ///
      /// Parent Type: `SearchResult`
      struct Search: API.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: Apollo.ParentType { API.Objects.SearchResult }
        static var __selections: [Apollo.Selection] { [
          .field("__typename", String.self),
          .field("result", [Result].self),
        ] }

        var result: [Result] { __data["result"] }

        /// Search.Result
        ///
        /// Parent Type: `SearchResultItem`
        struct Result: API.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: Apollo.ParentType { API.Interfaces.SearchResultItem }
          static var __selections: [Apollo.Selection] { [
            .field("__typename", String.self),
            .field("id", API.ID.self),
            .field("title", String.self),
            .field("description", String?.self),
            .field("image", String?.self),
            .field("highlight", String?.self),
            .field("url", String.self),
          ] }

          var id: API.ID { __data["id"] }
          var title: String { __data["title"] }
          var description: String? { __data["description"] }
          var image: String? { __data["image"] }
          var highlight: String? { __data["highlight"] }
          var url: String { __data["url"] }
        }
      }
    }
  }

}