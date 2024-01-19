// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetSetupQuery: GraphQLQuery {
  public static let operationName: String = "getSetup"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getSetup { me { __typename id bccMember analytics { __typename anonymousId } } application { __typename code clientVersion page { __typename id } searchPage { __typename id } } }"#
    ))

  public init() {}

  public struct Data: API.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { API.Objects.QueryRoot }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("me", Me.self),
      .field("application", Application.self),
    ] }

    public var me: Me { __data["me"] }
    public var application: Application { __data["application"] }

    /// Me
    ///
    /// Parent Type: `User`
    public struct Me: API.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { API.Objects.User }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", API.ID?.self),
        .field("bccMember", Bool.self),
        .field("analytics", Analytics.self),
      ] }

      public var id: API.ID? { __data["id"] }
      public var bccMember: Bool { __data["bccMember"] }
      public var analytics: Analytics { __data["analytics"] }

      /// Me.Analytics
      ///
      /// Parent Type: `Analytics`
      public struct Analytics: API.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { API.Objects.Analytics }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("anonymousId", String.self),
        ] }

        public var anonymousId: String { __data["anonymousId"] }
      }
    }

    /// Application
    ///
    /// Parent Type: `Application`
    public struct Application: API.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { API.Objects.Application }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("code", String.self),
        .field("clientVersion", String.self),
        .field("page", Page?.self),
        .field("searchPage", SearchPage?.self),
      ] }

      public var code: String { __data["code"] }
      public var clientVersion: String { __data["clientVersion"] }
      public var page: Page? { __data["page"] }
      public var searchPage: SearchPage? { __data["searchPage"] }

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

      /// Application.SearchPage
      ///
      /// Parent Type: `Page`
      public struct SearchPage: API.SelectionSet {
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
