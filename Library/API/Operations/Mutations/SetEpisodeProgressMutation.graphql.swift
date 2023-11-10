// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

extension API {
  class SetEpisodeProgressMutation: GraphQLMutation {
    static let operationName: String = "SetEpisodeProgress"
    static let operationDocument: Apollo.OperationDocument = .init(
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

    struct Data: API.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: Apollo.ParentType { API.Objects.MutationRoot }
      static var __selections: [Apollo.Selection] { [
        .field("setEpisodeProgress", SetEpisodeProgress.self, arguments: [
          "id": .variable("id"),
          "progress": .variable("progress")
        ]),
      ] }

      var setEpisodeProgress: SetEpisodeProgress { __data["setEpisodeProgress"] }

      /// SetEpisodeProgress
      ///
      /// Parent Type: `Episode`
      struct SetEpisodeProgress: API.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: Apollo.ParentType { API.Objects.Episode }
        static var __selections: [Apollo.Selection] { [
          .field("__typename", String.self),
          .field("id", API.ID.self),
        ] }

        var id: API.ID { __data["id"] }
      }
    }
  }

}