// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class SetEpisodeProgressMutation: GraphQLMutation {
  public static let operationName: String = "SetEpisodeProgress"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation SetEpisodeProgress($id: ID!, $progress: Int) { setEpisodeProgress(id: $id, progress: $progress) { __typename id } }"#
    ))

  public var id: ID
  public var progress: GraphQLNullable<Int>

  public init(
    id: ID,
    progress: GraphQLNullable<Int>
  ) {
    self.id = id
    self.progress = progress
  }

  public var __variables: Variables? { [
    "id": id,
    "progress": progress
  ] }

  public struct Data: API.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { API.Objects.MutationRoot }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("setEpisodeProgress", SetEpisodeProgress.self, arguments: [
        "id": .variable("id"),
        "progress": .variable("progress")
      ]),
    ] }

    public var setEpisodeProgress: SetEpisodeProgress { __data["setEpisodeProgress"] }

    /// SetEpisodeProgress
    ///
    /// Parent Type: `Episode`
    public struct SetEpisodeProgress: API.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { API.Objects.Episode }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", API.ID.self),
      ] }

      public var id: API.ID { __data["id"] }
    }
  }
}
