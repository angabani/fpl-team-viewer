//
//  FPLTeam.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import Foundation

// MARK: - FPLTeam

struct FPLTeam: Sendable, Hashable, Identifiable {
    let id: Int
    let name: String
    let shortName: String
    let players: [FPLPlayer]

    var playerCount: Int {
        players.count
    }

    /// Sum of all player prices, in tenths of a million like the API.
    var squadValue: Int {
        players.reduce(0) { $0 + $1.nowCost }
    }

    /// Player with most points, name breaks ties.
    /// Nil before anyone has scored, e.g. at the start of a season.
    var topPlayer: FPLPlayer? {
        let best = players.max { lhs, rhs in
            if lhs.totalPoints != rhs.totalPoints {
                return lhs.totalPoints < rhs.totalPoints
            }
            return lhs.webName.localizedStandardCompare(rhs.webName) == .orderedDescending
        }
        guard let best, best.totalPoints > 0 else { return nil }
        return best
    }

    /// Extra line on the team card, e.g. "£512.4m squad · Top: Saka 120 pts".
    var insightText: String {
        var parts = [FPLStringKey.squadValue(squadValue.fplPriceText)]
        if let topPlayer {
            parts.append(FPLStringKey.topPlayer(name: topPlayer.webName, points: topPlayer.totalPoints))
        }
        return parts.joined(separator: FPLStringKey.separator)
    }
}

// MARK: - FPLSquadSection

/// One position group on the squad screen.
struct FPLSquadSection: Sendable, Hashable {
    let position: FPLPosition
    let players: [FPLPlayer]
}

// MARK: - FPLTeamsSnapshot

/// Teams plus the time the data was fetched. Used for "Last updated".
struct FPLTeamsSnapshot: Sendable, Equatable {
    let teams: [FPLTeam]
    let updatedAt: Date
}
