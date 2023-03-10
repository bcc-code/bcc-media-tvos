// @generated
// This file was automatically generated and should not be edited.

import Apollo

public protocol API_SelectionSet: Apollo.SelectionSet & Apollo.RootSelectionSet
where Schema == API.SchemaMetadata {}

public protocol API_InlineFragment: Apollo.SelectionSet & Apollo.InlineFragment
where Schema == API.SchemaMetadata {}

public protocol API_MutableSelectionSet: Apollo.MutableRootSelectionSet
where Schema == API.SchemaMetadata {}

public protocol API_MutableInlineFragment: Apollo.MutableSelectionSet & Apollo.InlineFragment
where Schema == API.SchemaMetadata {}

public extension API {
  typealias ID = String

  typealias SelectionSet = API_SelectionSet

  typealias InlineFragment = API_InlineFragment

  typealias MutableSelectionSet = API_MutableSelectionSet

  typealias MutableInlineFragment = API_MutableInlineFragment

  enum SchemaMetadata: Apollo.SchemaMetadata {
    public static let configuration: Apollo.SchemaConfiguration.Type = SchemaConfiguration.self

    public static func objectType(forTypename typename: String) -> Object? {
      switch typename {
      case "QueryRoot": return API.Objects.QueryRoot
      case "Page": return API.Objects.Page
      default: return nil
      }
    }
  }

  enum Objects {}
  enum Interfaces {}
  enum Unions {}

}