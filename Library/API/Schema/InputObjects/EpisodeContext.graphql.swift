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
      collectionId: GraphQLNullable<String> = nil
    ) {
      __data = InputDict([
        "collectionId": collectionId
      ])
    }

    var collectionId: GraphQLNullable<String> {
      get { __data["collectionId"] }
      set { __data["collectionId"] = newValue }
    }
  }

}