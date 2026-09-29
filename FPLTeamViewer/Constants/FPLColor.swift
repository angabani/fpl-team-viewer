//
//  FPLColor.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import UIKit

private enum Constants {
    static let accentColorName = "AccentColor"
}

// MARK: - FPLColor

/// App colors. Asset catalog colors have light and dark variants,
/// so they update on their own when the appearance changes.
enum FPLColor {
    static let accent = UIColor(named: Constants.accentColorName) ?? .systemPurple
    /// Player may not play, e.g. doubtful.
    static let warning = UIColor.systemOrange
    /// Player will not play, e.g. injured or suspended.
    static let critical = UIColor.systemRed
}
