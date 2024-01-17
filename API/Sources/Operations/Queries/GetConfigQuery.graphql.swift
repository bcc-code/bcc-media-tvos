// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetConfigQuery: GraphQLQuery {
  public static let operationName: String = "GetConfig"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetConfig { application { __typename page { __typename code } } languages }"#
    ))

  public init() {}

  public struct Data: API.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { API.Objects.QueryRoot }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("application", Application.self),
      .field("languages", [API.Language].self),
    ] }

    public var application: Application { __data["application"] }
    public var languages: [API.Language] { __data["languages"] }

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
          .field("code", String.self),
        ] }

        public var code: String { __data["code"] }
      }
    }
  }
}
