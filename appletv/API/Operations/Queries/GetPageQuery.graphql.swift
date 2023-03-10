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
        ] }

        public var title: String { __data["title"] }
      }
    }
  }

}