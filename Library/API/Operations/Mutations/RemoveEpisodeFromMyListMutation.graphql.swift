// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

extension API {
  class RemoveEpisodeFromMyListMutation: GraphQLMutation {
    static let operationName: String = "RemoveEpisodeFromMyList"
    static let document: Apollo.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation RemoveEpisodeFromMyList($id: UUID!) {
          removeEntryFromMyList(entryId: $id) {
            __typename
            id
          }
        }
        """#
      ))

    public var id: UUID

    public init(id: UUID) {
      self.id = id
    }

    public var __variables: Variables? { ["id": id] }

    struct Data: API.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: Apollo.ParentType { API.Objects.MutationRoot }
      static var __selections: [Apollo.Selection] { [
        .field("removeEntryFromMyList", RemoveEntryFromMyList.self, arguments: ["entryId": .variable("id")]),
      ] }

      var removeEntryFromMyList: RemoveEntryFromMyList { __data["removeEntryFromMyList"] }

      /// RemoveEntryFromMyList
      ///
      /// Parent Type: `UserCollection`
      struct RemoveEntryFromMyList: API.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: Apollo.ParentType { API.Objects.UserCollection }
        static var __selections: [Apollo.Selection] { [
          .field("__typename", String.self),
          .field("id", API.UUID.self),
        ] }

        var id: API.UUID { __data["id"] }
      }
    }
  }

}