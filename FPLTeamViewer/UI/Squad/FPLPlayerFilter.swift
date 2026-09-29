//
//  FPLPlayerFilter.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import Foundation

// MARK: - FPLPlayerFilter

/// Search logic for the squad screen. Kept pure so it is easy to test.
enum FPLPlayerFilter {
    /// Matches on short name or full name. Ignores case, accents and extra spaces.
    /// Empty query returns all players.
    static func filter(_ players: [FPLPlayer], query: String) -> [FPLPlayer] {
        let query = normalize(query)
        guard !query.isEmpty else { return players }

        return players.filter { player in
            normalize(player.webName).contains(query) || normalize(player.fullName).contains(query)
        }
    }

    static func normalize(_ text: String) -> String {
        text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
    }
}
