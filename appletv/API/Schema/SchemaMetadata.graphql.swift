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
      case "SectionPagination": return API.Objects.SectionPagination
      case "AchievementGroupPagination": return API.Objects.AchievementGroupPagination
      case "AchievementPagination": return API.Objects.AchievementPagination
      case "CollectionItemPagination": return API.Objects.CollectionItemPagination
      case "EpisodePagination": return API.Objects.EpisodePagination
      case "FAQCategoryPagination": return API.Objects.FAQCategoryPagination
      case "LessonPagination": return API.Objects.LessonPagination
      case "LinkPagination": return API.Objects.LinkPagination
      case "QuestionPagination": return API.Objects.QuestionPagination
      case "SeasonPagination": return API.Objects.SeasonPagination
      case "SectionItemPagination": return API.Objects.SectionItemPagination
      case "SurveyQuestionPagination": return API.Objects.SurveyQuestionPagination
      case "TaskPagination": return API.Objects.TaskPagination
      case "UserCollectionEntryPagination": return API.Objects.UserCollectionEntryPagination
      case "AchievementSection": return API.Objects.AchievementSection
      case "CardListSection": return API.Objects.CardListSection
      case "CardSection": return API.Objects.CardSection
      case "DefaultGridSection": return API.Objects.DefaultGridSection
      case "IconGridSection": return API.Objects.IconGridSection
      case "PosterGridSection": return API.Objects.PosterGridSection
      case "DefaultSection": return API.Objects.DefaultSection
      case "FeaturedSection": return API.Objects.FeaturedSection
      case "IconSection": return API.Objects.IconSection
      case "LabelSection": return API.Objects.LabelSection
      case "ListSection": return API.Objects.ListSection
      case "PosterSection": return API.Objects.PosterSection
      case "MessageSection": return API.Objects.MessageSection
      case "PageDetailsSection": return API.Objects.PageDetailsSection
      case "WebSection": return API.Objects.WebSection
      case "SectionItem": return API.Objects.SectionItem
      default: return nil
      }
    }
  }

  enum Objects {}
  enum Interfaces {}
  enum Unions {}

}