//
//  FPLLayoutConstants.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import Foundation

// MARK: - FPLLayoutConstants

/// Layout values shared by more than one view.
/// Values used by a single view stay private in that file.
/// All spacing sits on a 4pt grid.
enum FPLLayoutConstants {
    // MARK: - Spacing scale

    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 12
    static let spacingL: CGFloat = 16
    static let spacingXL: CGFloat = 24

    // MARK: - Cards

    static let cardCornerRadius: CGFloat = 12
    /// Card edge to its content.
    static let cardPadding = spacingL
    /// Gap between cards, both between rows and between columns.
    static let gridSpacing = spacingL
    /// Each card is inset by half the grid gap on both sides, so two cards side by side
    /// get a full gap between them. Done inside the cell so self-sizing measures the right width.
    static let cardGutter = gridSpacing / 2
    /// Gap between items in a card row, e.g. badge, text and price.
    static let contentSpacing = spacingM
    /// Gap between stacked lines of text.
    static let labelSpacing = spacingXS
}
