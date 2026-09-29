//
//  FPLPlayerStatus.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import Foundation

// MARK: - FPLPlayerStatus

/// Player availability. Raw value matches `status` in the API.
enum FPLPlayerStatus: String, Sendable, Hashable {
    case available = "a"
    case doubtful = "d"
    case injured = "i"
    case suspended = "s"
    /// Left the club, on loan, or otherwise not available.
    case unavailable = "u"
    case notInSquad = "n"

    /// Unknown or missing codes count as available, so nobody gets a false warning.
    init(code: String?) {
        self = code.flatMap(FPLPlayerStatus.init(rawValue:)) ?? .available
    }

    var title: String {
        switch self {
        case .available: FPLStringKey.statusAvailable
        case .doubtful: FPLStringKey.statusDoubtful
        case .injured: FPLStringKey.statusInjured
        case .suspended: FPLStringKey.statusSuspended
        case .unavailable: FPLStringKey.statusUnavailable
        case .notInSquad: FPLStringKey.statusNotInSquad
        }
    }

    /// Doubtful is a warning. Everything else that is not available means the player will not play.
    var isWarning: Bool {
        self == .doubtful
    }
}
