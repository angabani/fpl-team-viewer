//
//  FPLPlayerDTO.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import Foundation

// MARK: - FPLPlayerDTO

/// A player as it comes from the API (`elements` array).
struct FPLPlayerDTO: Decodable, Sendable {
    let id: Int
    let firstName: String
    let secondName: String
    let webName: String
    /// Team id.
    let team: Int
    /// Position id. 1 GKP, 2 DEF, 3 MID, 4 FWD.
    let elementType: Int
    /// Price in tenths of a million. 61 means £6.1m.
    let nowCost: Int
    let totalPoints: Int
    /// Availability code: a, d, i, s, u, n. Optional so an older cache still decodes.
    let status: String?
    /// Sent as text by the API, e.g. "6.0".
    let form: String?
    /// Sent as text by the API, e.g. "42.3".
    let selectedByPercent: String?
    /// Injury or transfer note, e.g. "Groin injury - 75% chance of playing".
    let news: String?
}
