// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

extension API {
  class GetEpisodeQuery: GraphQLQuery {
    static let operationName: String = "GetEpisode"
    static let document: Apollo.DocumentType = .notPersisted(
      definition: .init(
        #"""
        query GetEpisode($id: ID!, $context: EpisodeContext) {
          episode(id: $id, context: $context) {
            __typename
            id
            uuid
            type
            title
            image
            ageRating
            publishDate
            description
            progress
            locked
            inMyList
            next {
              __typename
              id
            }
            season {
              __typename
              id
              title
              show {
                __typename
                id
                title
              }
            }
          }
        }
        """#
      ))

    public var id: ID
    public var context: GraphQLNullable<EpisodeContext>

    public init(
      id: ID,
      context: GraphQLNullable<EpisodeContext>
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
          .field("uuid", String.self),
          .field("type", GraphQLEnum<API.EpisodeType>.self),
          .field("title", String.self),
          .field("image", String?.self),
          .field("ageRating", String.self),
          .field("publishDate", API.Date.self),
          .field("description", String.self),
          .field("progress", Int?.self),
          .field("locked", Bool.self),
          .field("inMyList", Bool.self),
          .field("next", [Next].self),
          .field("season", Season?.self),
        ] }

        var id: API.ID { __data["id"] }
        var uuid: String { __data["uuid"] }
        var type: GraphQLEnum<API.EpisodeType> { __data["type"] }
        var title: String { __data["title"] }
        var image: String? { __data["image"] }
        var ageRating: String { __data["ageRating"] }
        var publishDate: API.Date { __data["publishDate"] }
        var description: String { __data["description"] }
        var progress: Int? { __data["progress"] }
        var locked: Bool { __data["locked"] }
        var inMyList: Bool { __data["inMyList"] }
        /// Should probably be used asynchronously, and retrieved separately from the episode, as it can be slow in some cases (a few db requests can occur)
        var next: [Next] { __data["next"] }
        var season: Season? { __data["season"] }

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

        /// Episode.Season
        ///
        /// Parent Type: `Season`
        struct Season: API.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: Apollo.ParentType { API.Objects.Season }
          static var __selections: [Apollo.Selection] { [
            .field("__typename", String.self),
            .field("id", API.ID.self),
            .field("title", String.self),
            .field("show", Show.self),
          ] }

          var id: API.ID { __data["id"] }
          var title: String { __data["title"] }
          var show: Show { __data["show"] }

          /// Episode.Season.Show
          ///
          /// Parent Type: `Show`
          struct Show: API.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: Apollo.ParentType { API.Objects.Show }
            static var __selections: [Apollo.Selection] { [
              .field("__typename", String.self),
              .field("id", API.ID.self),
              .field("title", String.self),
            ] }

            var id: API.ID { __data["id"] }
            var title: String { __data["title"] }
          }
        }
      }
    }
  }

}