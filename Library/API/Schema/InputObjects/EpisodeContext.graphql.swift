// @generated
// This file was automatically generated and should not be edited.

import Apollo

extension API {
  struct EpisodeContext: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      collectionId: GraphQLNullable<String> = nil,
      playlistId: GraphQLNullable<String> = nil,
      shuffle: GraphQLNullable<Bool> = nil,
      cursor: GraphQLNullable<String> = nil
    ) {
      __data = InputDict([
        "collectionId": collectionId,
        "playlistId": playlistId,
        "shuffle": shuffle,
        "cursor": cursor
      ])
    }

    var collectionId: GraphQLNullable<String> {
      get { __data["collectionId"] }
      set { __data["collectionId"] = newValue }
    }

    var playlistId: GraphQLNullable<String> {
      get { __data["playlistId"] }
      set { __data["playlistId"] = newValue }
    }

    var shuffle: GraphQLNullable<Bool> {
      get { __data["shuffle"] }
      set { __data["shuffle"] = newValue }
    }

    var cursor: GraphQLNullable<String> {
      get { __data["cursor"] }
      set { __data["cursor"] = newValue }
    }
  }

}