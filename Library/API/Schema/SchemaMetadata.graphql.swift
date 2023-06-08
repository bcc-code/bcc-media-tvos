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
      case "Calendar": return API.Objects.Calendar
      case "CalendarDay": return API.Objects.CalendarDay
      case "Event": return API.Objects.Event
      case "EpisodeCalendarEntry": return API.Objects.EpisodeCalendarEntry
      case "SeasonCalendarEntry": return API.Objects.SeasonCalendarEntry
      case "ShowCalendarEntry": return API.Objects.ShowCalendarEntry
      case "SimpleCalendarEntry": return API.Objects.SimpleCalendarEntry
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
      case "ItemSectionMetadata": return API.Objects.ItemSectionMetadata
      case "SectionItem": return API.Objects.SectionItem
      case "Show": return API.Objects.Show
      case "Season": return API.Objects.Season
      case "Episode": return API.Objects.Episode
      case "Link": return API.Objects.Link
      case "StudyTopic": return API.Objects.StudyTopic
      case "Game": return API.Objects.Game
      case "SearchResult": return API.Objects.SearchResult
      case "EpisodeSearchItem": return API.Objects.EpisodeSearchItem
      case "SeasonSearchItem": return API.Objects.SeasonSearchItem
      case "ShowSearchItem": return API.Objects.ShowSearchItem
      case "Stream": return API.Objects.Stream
      case "ContextCollection": return API.Objects.ContextCollection
      case "Lesson": return API.Objects.Lesson
      case "MutationRoot": return API.Objects.MutationRoot
      case "User": return API.Objects.User
      case "Analytics": return API.Objects.Analytics
      case "Application": return API.Objects.Application
      default: return nil
      }
    }
  }

  enum Objects {}
  enum Interfaces {}
  enum Unions {}

}