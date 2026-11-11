//
//  DeepLink.swift
//  BCC Media tvOS
//

import Foundation

/// An incoming link the app can act on.
struct EpisodeDeepLink: Equatable {
    let episodeId: String
    let play: Bool
}

/// Parses an incoming universal/custom-scheme link.
///
/// Returns `nil` for anything that isn't an actionable episode link: a URL
/// `URLComponents` can't parse, a path that isn't `/episode/<id>`, or an episode
/// path with no id. Deep links arrive from outside the app, so none of that can be
/// assumed away.
func parseEpisodeDeepLink(_ url: URL) -> EpisodeDeepLink? {
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
        print("ignoring unparseable deep link: \(url)")
        return nil
    }

    // `count >= 2` is the fix: the id was read unconditionally once the first component matched,
    // so a link of just `…://episode` was an index-out-of-range. `split(separator:)` already drops
    // empty segments, so an actionable episode link always has both parts — a path of just
    // "/episode" carries no id to load.
    let parts = components.path.split(separator: "/")
    guard parts.count >= 2, parts[0] == "episode" else {
        return nil
    }

    let play = components.queryItems?.contains { $0.name == "play" } == true
    return EpisodeDeepLink(episodeId: String(parts[1]), play: play)
}

enum EpisodeOverride: Equatable {
    case episode(EpisodeDeepLink)
    case external(URL)
}

private let appUrlScheme = "bcc.media"

private func isOwnUrl(_ url: URL) -> Bool {
    guard let scheme = url.scheme?.lowercased() else {
        return false
    }
    if scheme == appUrlScheme {
        return true
    }
    guard scheme == "http" || scheme == "https", let host = url.host?.lowercased() else {
        return false
    }
    return host == "bcc.media" || host.hasSuffix(".bcc.media")
}

/// Returns nil when the episode itself should be shown.
func resolveEpisodeOverride(_ raw: String?, currentEpisodeId: String) -> EpisodeOverride? {
    guard let trimmed = raw?.trimmingCharacters(in: .whitespacesAndNewlines),
          !trimmed.isEmpty,
          let url = URL(string: trimmed)
    else {
        return nil
    }

    // No scheme means a path relative to our own app/site.
    if url.scheme == nil || isOwnUrl(url) {
        guard let link = parseEpisodeDeepLink(url), link.episodeId != currentEpisodeId else {
            return nil
        }
        return .episode(link)
    }

    return .external(url)
}
