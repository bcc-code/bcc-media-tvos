// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct EpisodeContext: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
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

  public var collectionId: GraphQLNullable<String> {
    get { __data["collectionId"] }
    set { __data["collectionId"] = newValue }
  }

  public var playlistId: GraphQLNullable<String> {
    get { __data["playlistId"] }
    set { __data["playlistId"] = newValue }
  }

  public var shuffle: GraphQLNullable<Bool> {
    get { __data["shuffle"] }
    set { __data["shuffle"] = newValue }
  }

  public var cursor: GraphQLNullable<String> {
    get { __data["cursor"] }
    set { __data["cursor"] = newValue }
  }
}
