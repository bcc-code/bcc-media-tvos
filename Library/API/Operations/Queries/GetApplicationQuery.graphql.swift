// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

public extension API {
  class GetApplicationQuery: GraphQLQuery {
    public static let operationName: String = "getApplication"
    public static let document: Apollo.DocumentType = .notPersisted(
      definition: .init(
        #"""
        query getApplication {
          application {
            __typename
            page {
              __typename
              id
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
        .field("application", Application.self),
      ] }

      public var application: Application { __data["application"] }

      /// Application
      ///
      /// Parent Type: `Application`
      public struct Application: API.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: Apollo.ParentType { API.Objects.Application }
        public static var __selections: [Apollo.Selection] { [
          .field("page", Page?.self),
        ] }

        public var page: Page? { __data["page"] }

        /// Application.Page
        ///
        /// Parent Type: `Page`
        public struct Page: API.SelectionSet {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: Apollo.ParentType { API.Objects.Page }
          public static var __selections: [Apollo.Selection] { [
            .field("id", API.ID.self),
          ] }

          public var id: API.ID { __data["id"] }
        }
      }
    }
  }

}