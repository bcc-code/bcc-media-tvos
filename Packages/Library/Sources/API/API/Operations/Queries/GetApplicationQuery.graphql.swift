// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension API {
  class GetApplicationQuery: GraphQLQuery {
    public static let operationName: String = "getApplication"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
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
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { API.Objects.QueryRoot }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("application", Application.self),
      ] }

      public var application: Application { __data["application"] }

      /// Application
      ///
      /// Parent Type: `Application`
      public struct Application: API.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { API.Objects.Application }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("page", Page?.self),
        ] }

        public var page: Page? { __data["page"] }

        /// Application.Page
        ///
        /// Parent Type: `Page`
        public struct Page: API.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { API.Objects.Page }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", API.ID.self),
          ] }

          public var id: API.ID { __data["id"] }
        }
      }
    }
  }

}