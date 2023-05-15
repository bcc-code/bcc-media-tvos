// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

public extension API {
  class SetEpisodeProgressMutation: GraphQLMutation {
    public static let operationName: String = "SetEpisodeProgress"
    public static let document: Apollo.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation SetEpisodeProgress($id: ID!, $progress: Int!) {
          setEpisodeProgress(id: $id, progress: $progress) {
            __typename
            id
          }
        }
        """#
      ))

    public var id: ID
    public var progress: Int

    public init(
      id: ID,
      progress: Int
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

      public static var __parentType: Apollo.ParentType { API.Objects.MutationRoot }
      public static var __selections: [Apollo.Selection] { [
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

        public static var __parentType: Apollo.ParentType { API.Objects.Episode }
        public static var __selections: [Apollo.Selection] { [
          .field("__typename", String.self),
          .field("id", API.ID.self),
        ] }

        public var id: API.ID { __data["id"] }
      }
    }
  }

}