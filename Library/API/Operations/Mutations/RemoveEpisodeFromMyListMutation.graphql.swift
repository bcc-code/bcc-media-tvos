// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

public extension API {
  class RemoveEpisodeFromMyListMutation: GraphQLMutation {
    public static let operationName: String = "RemoveEpisodeFromMyList"
    public static let document: Apollo.DocumentType = .notPersisted(
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

    public struct Data: API.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: Apollo.ParentType { API.Objects.MutationRoot }
      public static var __selections: [Apollo.Selection] { [
        .field("removeEntryFromMyList", RemoveEntryFromMyList.self, arguments: ["entryId": .variable("id")]),
      ] }

      public var removeEntryFromMyList: RemoveEntryFromMyList { __data["removeEntryFromMyList"] }

      /// RemoveEntryFromMyList
      ///
      /// Parent Type: `UserCollection`
      public struct RemoveEntryFromMyList: API.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: Apollo.ParentType { API.Objects.UserCollection }
        public static var __selections: [Apollo.Selection] { [
          .field("__typename", String.self),
          .field("id", API.UUID.self),
        ] }

        public var id: API.UUID { __data["id"] }
      }
    }
  }

}