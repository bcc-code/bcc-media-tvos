// @generated
// This file was automatically generated and should not be edited.

import Apollo

public extension API {
  struct EpisodeContext: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      collectionId: GraphQLNullable<String> = nil
    ) {
      __data = InputDict([
        "collectionId": collectionId
      ])
    }

    public var collectionId: GraphQLNullable<String> {
      get { __data["collectionId"] }
      set { __data["collectionId"] = newValue }
    }
  }

}