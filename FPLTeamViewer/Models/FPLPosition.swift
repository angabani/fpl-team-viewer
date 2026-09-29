//
//  FPLPosition.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import Foundation

// MARK: - FPLPosition

/// Player position. Raw value matches `element_type` in the API.
/// Case order is also the order of sections in the squad screen.
enum FPLPosition: Int, CaseIterable, Sendable, Hashable {
    case goalkeeper = 1
    case defender = 2
    case midfielder = 3
    case forward = 4

    var title: String {
        switch self {
        case .goalkeeper: FPLStringKey.goalkeepers
        case .defender: FPLStringKey.defenders
        case .midfielder: FPLStringKey.midfielders
        case .forward: FPLStringKey.forwards
        }
    }

    var shortName: String {
        switch self {
        case .goalkeeper: FPLStringKey.goalkeeperShort
        case .defender: FPLStringKey.defenderShort
        case .midfielder: FPLStringKey.midfielderShort
        case .forward: FPLStringKey.forwardShort
        }
    }
}
