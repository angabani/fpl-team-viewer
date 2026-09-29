//
//  IFPLNavigator.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import Foundation

// MARK: - IFPLNavigator

/// What screens can ask for. Screens never push other screens themselves.
@MainActor
protocol IFPLNavigator: AnyObject {
    func showSquad(for team: FPLTeam)
}
