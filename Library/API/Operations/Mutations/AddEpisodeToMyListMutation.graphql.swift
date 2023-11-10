// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

extension API {
  class AddEpisodeToMyListMutation: GraphQLMutation {
    static let operationName: String = "AddEpisodeToMyList"
    static let operationDocument: Apollo.OperationDocument = .init(
      definition: .init(
        #"mutation AddEpisodeToMyList($id: ID!) { addEpisodeToMyList(episodeId: $id) { __typename entryId } }"#
      ))

    public var id: ID

    public init(id: ID) {
      self.id = id
    }

    public var __variables: Variables? { ["id": id] }

    struct Data: API.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: Apollo.ParentType { API.Objects.MutationRoot }
      static var __selections: [Apollo.Selection] { [
        .field("addEpisodeToMyList", AddEpisodeToMyList.self, arguments: ["episodeId": .variable("id")]),
      ] }

      var addEpisodeToMyList: AddEpisodeToMyList { __data["addEpisodeToMyList"] }

      /// AddEpisodeToMyList
      ///
      /// Parent Type: `AddToCollectionResult`
      struct AddEpisodeToMyList: API.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: Apollo.ParentType { API.Objects.AddToCollectionResult }
        static var __selections: [Apollo.Selection] { [
          .field("__typename", String.self),
          .field("entryId", API.UUID.self),
        ] }

        var entryId: API.UUID { __data["entryId"] }
      }
    }
  }

}