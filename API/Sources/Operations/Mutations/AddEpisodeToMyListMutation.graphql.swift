// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class AddEpisodeToMyListMutation: GraphQLMutation {
  public static let operationName: String = "AddEpisodeToMyList"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation AddEpisodeToMyList($id: ID!) { addEpisodeToMyList(episodeId: $id) { __typename entryId } }"#
    ))

  public var id: ID

  public init(id: ID) {
    self.id = id
  }

  public var __variables: Variables? { ["id": id] }

  public struct Data: API.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { API.Objects.MutationRoot }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("addEpisodeToMyList", AddEpisodeToMyList.self, arguments: ["episodeId": .variable("id")]),
    ] }

    public var addEpisodeToMyList: AddEpisodeToMyList { __data["addEpisodeToMyList"] }

    /// AddEpisodeToMyList
    ///
    /// Parent Type: `AddToCollectionResult`
    public struct AddEpisodeToMyList: API.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { API.Objects.AddToCollectionResult }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("entryId", API.UUID.self),
      ] }

      public var entryId: API.UUID { __data["entryId"] }
    }
  }
}
