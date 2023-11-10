// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

extension API {
  class GetSetupQuery: GraphQLQuery {
    static let operationName: String = "getSetup"
    static let operationDocument: Apollo.OperationDocument = .init(
      definition: .init(
        #"query getSetup { me { __typename id bccMember analytics { __typename anonymousId } } application { __typename code clientVersion page { __typename id } searchPage { __typename id } } }"#
      ))

    public init() {}

    struct Data: API.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: Apollo.ParentType { API.Objects.QueryRoot }
      static var __selections: [Apollo.Selection] { [
        .field("me", Me.self),
        .field("application", Application.self),
      ] }

      var me: Me { __data["me"] }
      var application: Application { __data["application"] }

      /// Me
      ///
      /// Parent Type: `User`
      struct Me: API.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: Apollo.ParentType { API.Objects.User }
        static var __selections: [Apollo.Selection] { [
          .field("__typename", String.self),
          .field("id", API.ID?.self),
          .field("bccMember", Bool.self),
          .field("analytics", Analytics.self),
        ] }

        var id: API.ID? { __data["id"] }
        var bccMember: Bool { __data["bccMember"] }
        var analytics: Analytics { __data["analytics"] }

        /// Me.Analytics
        ///
        /// Parent Type: `Analytics`
        struct Analytics: API.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: Apollo.ParentType { API.Objects.Analytics }
          static var __selections: [Apollo.Selection] { [
            .field("__typename", String.self),
            .field("anonymousId", String.self),
          ] }

          var anonymousId: String { __data["anonymousId"] }
        }
      }

      /// Application
      ///
      /// Parent Type: `Application`
      struct Application: API.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: Apollo.ParentType { API.Objects.Application }
        static var __selections: [Apollo.Selection] { [
          .field("__typename", String.self),
          .field("code", String.self),
          .field("clientVersion", String.self),
          .field("page", Page?.self),
          .field("searchPage", SearchPage?.self),
        ] }

        var code: String { __data["code"] }
        var clientVersion: String { __data["clientVersion"] }
        var page: Page? { __data["page"] }
        var searchPage: SearchPage? { __data["searchPage"] }

        /// Application.Page
        ///
        /// Parent Type: `Page`
        struct Page: API.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: Apollo.ParentType { API.Objects.Page }
          static var __selections: [Apollo.Selection] { [
            .field("__typename", String.self),
            .field("id", API.ID.self),
          ] }

          var id: API.ID { __data["id"] }
        }

        /// Application.SearchPage
        ///
        /// Parent Type: `Page`
        struct SearchPage: API.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: Apollo.ParentType { API.Objects.Page }
          static var __selections: [Apollo.Selection] { [
            .field("__typename", String.self),
            .field("id", API.ID.self),
          ] }

          var id: API.ID { __data["id"] }
        }
      }
    }
  }

}