//
//  FPLPlayer.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import Foundation

// MARK: - FPLPlayer

struct FPLPlayer: Sendable, Hashable, Identifiable {
    let id: Int
    let firstName: String
    let secondName: String
    /// Short display name used by FPL, e.g. "Saka".
    let webName: String
    let teamID: Int
    let position: FPLPosition
    /// Price in tenths of a million, same as the API.
    let nowCost: Int
    let totalPoints: Int
    let status: FPLPlayerStatus
    /// Injury or transfer note from the API. Empty when there is none.
    let news: String
    /// Average points over the last few games.
    let form: Double
    /// Share of FPL managers who picked this player, in percent.
    let selectedByPercent: Double

    /// Text to show when the player may not play. Nil when available.
    var availabilityText: String? {
        guard status != .available else { return nil }
        return news.isEmpty ? status.title : news
    }

    var fullName: String {
        "\(firstName) \(secondName)"
    }

    var priceText: String {
        nowCost.fplPriceText
    }

    /// e.g. "Form 6.0 · 42.3% selected".
    var statsText: String {
        FPLStringKey.playerStats(form: form.fplOneDecimalText, selectedByPercent: selectedByPercent.fplOneDecimalText)
    }
}
