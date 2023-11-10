// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

extension API {
  class GetNextEpisodeQuery: GraphQLQuery {
    static let operationName: String = "GetNextEpisode"
    static let operationDocument: Apollo.OperationDocument = .init(
      definition: .init(
        #"query GetNextEpisode($id: ID!, $context: EpisodeContext!) { episode(id: $id, context: $context) { __typename id cursor next { __typename id } } }"#
      ))

    public var id: ID
    public var context: EpisodeContext

    public init(
      id: ID,
      context: EpisodeContext
    ) {
      self.id = id
      self.context = context
    }

    public var __variables: Variables? { [
      "id": id,
      "context": context
    ] }

    struct Data: API.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: Apollo.ParentType { API.Objects.QueryRoot }
      static var __selections: [Apollo.Selection] { [
        .field("episode", Episode.self, arguments: [
          "id": .variable("id"),
          "context": .variable("context")
        ]),
      ] }

      var episode: Episode { __data["episode"] }

      /// Episode
      ///
      /// Parent Type: `Episode`
      struct Episode: API.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: Apollo.ParentType { API.Objects.Episode }
        static var __selections: [Apollo.Selection] { [
          .field("__typename", String.self),
          .field("id", API.ID.self),
          .field("cursor", String.self),
          .field("next", [Next].self),
        ] }

        var id: API.ID { __data["id"] }
        var cursor: String { __data["cursor"] }
        /// Should probably be used asynchronously, and retrieved separately from the episode, as it can be slow in some cases (a few db requests can occur)
        var next: [Next] { __data["next"] }

        /// Episode.Next
        ///
        /// Parent Type: `Episode`
        struct Next: API.SelectionSet {
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

}