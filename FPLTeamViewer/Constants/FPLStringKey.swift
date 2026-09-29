//
//  FPLStringKey.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import Foundation

// MARK: - FPLStringKey

/// All user facing text in one place. `String(localized:)` makes it ready for translation.
enum FPLStringKey {
    // MARK: - Screens

    static let teamsTitle = String(localized: "Teams")
    static let selectTeamTitle = String(localized: "Select a team")
    static let selectTeamMessage = String(localized: "Pick a team to see its squad.")
    static let searchPlayersPlaceholder = String(localized: "Search players")

    // MARK: - Positions

    static let goalkeepers = String(localized: "Goalkeepers")
    static let defenders = String(localized: "Defenders")
    static let midfielders = String(localized: "Midfielders")
    static let forwards = String(localized: "Forwards")

    static let goalkeeperShort = "GKP"
    static let defenderShort = "DEF"
    static let midfielderShort = "MID"
    static let forwardShort = "FWD"

    // MARK: - Player status

    static let statusAvailable = String(localized: "Available")
    static let statusDoubtful = String(localized: "Doubtful")
    static let statusInjured = String(localized: "Injured")
    static let statusSuspended = String(localized: "Suspended")
    static let statusUnavailable = String(localized: "Unavailable")
    static let statusNotInSquad = String(localized: "Not in squad")

    // MARK: - Labels

    static let separator = " · "

    /// e.g. "ARS · 29 players".
    static func teamDetail(shortName: String, playerCount: Int) -> String {
        shortName + separator + self.playerCount(playerCount)
    }

    /// e.g. "£512.4m squad".
    static func squadValue(_ price: String) -> String {
        String(localized: "\(price) squad")
    }

    /// e.g. "Top: Saka 120 pts".
    static func topPlayer(name: String, points: Int) -> String {
        String(localized: "Top: \(name) \(self.points(points))")
    }

    /// e.g. "Form 6.0 · 42.3% selected".
    static func playerStats(form: String, selectedByPercent: String) -> String {
        String(localized: "Form \(form)") + separator + String(localized: "\(selectedByPercent)% selected")
    }

    static func teamAccessibility(name: String, playerCount: Int, extra: String) -> String {
        "\(name), \(self.playerCount(playerCount)), \(extra)"
    }

    static func playerAccessibility(
        fullName: String,
        position: String,
        price: String,
        points: Int,
        stats: String,
        availability: String?
    ) -> String {
        [fullName, position, price, self.points(points), stats, availability]
            .compactMap { $0 }
            .joined(separator: ", ")
    }

    static func sectionAccessibility(title: String, playerCount: Int) -> String {
        "\(title), \(self.playerCount(playerCount))"
    }

    /// e.g. "£6.1m".
    static func price(_ millions: String) -> String {
        "£\(millions)m"
    }

    static func playerCount(_ count: Int) -> String {
        count == 1 ? String(localized: "1 player") : String(localized: "\(count) players")
    }

    static func points(_ points: Int) -> String {
        points == 1 ? String(localized: "1 pt") : String(localized: "\(points) pts")
    }

    static func lastUpdated(_ date: Date) -> String {
        String(localized: "Last updated \(date.fplShortText)")
    }

    // MARK: - States

    static let loadingTeams = String(localized: "Loading teams…")
    static let noTeamsTitle = String(localized: "No teams")
    static let noTeamsMessage = String(localized: "The API returned no teams. Try again later.")
    static let noPlayersTitle = String(localized: "No players")
    static let noPlayersMessage = String(localized: "This team has no players listed yet.")
    static let noResultsTitle = String(localized: "No results")

    static func noResultsMessage(_ query: String) -> String {
        String(localized: "No players match \"\(query)\".")
    }

    static let errorTitle = String(localized: "Couldn't load teams")
    static let retry = String(localized: "Retry")
    static let reload = String(localized: "Reload")
    static let refreshFailed = String(localized: "Couldn't refresh. Showing last saved data.")

    // MARK: - Errors

    static let errorNoInternet = String(localized: "You're offline. Check your connection and try again.")
    static let errorTimeout = String(localized: "The request timed out. Please try again.")
    static let errorServer = String(localized: "The FPL server is not responding right now.")
    static let errorDecoding = String(localized: "We got data we couldn't read.")
    static let errorGeneric = String(localized: "Something went wrong. Please try again.")
}
