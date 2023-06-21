// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

extension API {
  class GetConfigQuery: GraphQLQuery {
    static let operationName: String = "GetConfig"
    static let document: Apollo.DocumentType = .notPersisted(
      definition: .init(
        #"""
        query GetConfig {
          application {
            __typename
            page {
              __typename
              code
            }
          }
          languages
        }
        """#
      ))

    public init() {}

    struct Data: API.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: Apollo.ParentType { API.Objects.QueryRoot }
      static var __selections: [Apollo.Selection] { [
        .field("application", Application.self),
        .field("languages", [API.Language].self),
      ] }

      var application: Application { __data["application"] }
      var languages: [API.Language] { __data["languages"] }

      /// Application
      ///
      /// Parent Type: `Application`
      struct Application: API.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: Apollo.ParentType { API.Objects.Application }
        static var __selections: [Apollo.Selection] { [
          .field("__typename", String.self),
          .field("page", Page?.self),
        ] }

        var page: Page? { __data["page"] }

        /// Application.Page
        ///
        /// Parent Type: `Page`
        struct Page: API.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: Apollo.ParentType { API.Objects.Page }
          static var __selections: [Apollo.Selection] { [
            .field("__typename", String.self),
            .field("code", String.self),
          ] }

          var code: String { __data["code"] }
        }
      }
    }
  }

}