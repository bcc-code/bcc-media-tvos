// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

extension API {
  class GetEpisodeSeasonQuery: GraphQLQuery {
    static let operationName: String = "GetEpisodeSeason"
    static let document: Apollo.DocumentType = .notPersisted(
      definition: .init(
        #"""
        query GetEpisodeSeason($id: ID!) {
          season(id: $id) {
            __typename
            ...EpisodeSeason
          }
        }
        """#,
        fragments: [EpisodeSeason.self]
      ))

    public var id: ID

    public init(id: ID) {
      self.id = id
    }

    public var __variables: Variables? { ["id": id] }

    struct Data: API.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: Apollo.ParentType { API.Objects.QueryRoot }
      static var __selections: [Apollo.Selection] { [
        .field("season", Season.self, arguments: ["id": .variable("id")]),
      ] }

      var season: Season { __data["season"] }

      /// Season
      ///
      /// Parent Type: `Season`
      struct Season: API.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: Apollo.ParentType { API.Objects.Season }
        static var __selections: [Apollo.Selection] { [
          .field("__typename", String.self),
          .fragment(EpisodeSeason.self),
        ] }

        var title: String { __data["title"] }
        var show: EpisodeSeason.Show { __data["show"] }
        var episodes: EpisodeSeason.Episodes { __data["episodes"] }

        struct Fragments: FragmentContainer {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          var episodeSeason: EpisodeSeason { _toFragment() }
        }
      }
    }
  }

}