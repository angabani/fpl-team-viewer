//
//  FPLGridLayout.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import UIKit

private enum Constants {
    static let sectionTopInset = FPLLayoutConstants.spacingS
    static let sectionBottomInset = FPLLayoutConstants.spacingXL
    static let estimatedHeaderHeight: CGFloat = 40
    /// Narrowest a card can be at default text size and still fit its content.
    /// Not a device breakpoint: columns are however many cards of this width fit.
    static let minimumCardWidth: CGFloat = 320
    static let minimumColumns = 1
}

// MARK: - FPLGridLayout

/// Card grid used by both screens.
/// Column count comes from the width the collection view has right now,
/// so it reflows on rotation, fold/unfold, split view resize and text size change.
@MainActor
enum FPLGridLayout {
    static let sectionHeaderKind = UICollectionView.elementKindSectionHeader

    static func make(estimatedItemHeight: CGFloat, showsHeaders: Bool) -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { _, environment in
            let spacing = FPLLayoutConstants.gridSpacing
            // Bigger text needs wider cards, so scale the minimum with Dynamic Type.
            let minimumCardWidth = UIFontMetrics.default.scaledValue(
                for: Constants.minimumCardWidth,
                compatibleWith: environment.traitCollection
            )
            let columns = columnCount(
                for: environment.container.effectiveContentSize.width,
                minimumCardWidth: minimumCardWidth,
                spacing: spacing
            )

            // Each card takes an equal share of the row, so the row never gets wider than the screen.
            // The gap between cards is drawn inside each cell (see FPLLayoutConstants.cardGutter).
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1 / CGFloat(columns)),
                heightDimension: .estimated(estimatedItemHeight)
            ))

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(estimatedItemHeight)
                ),
                subitems: [item]
            )

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = spacing
            section.contentInsetsReference = .layoutMargins
            section.contentInsets = NSDirectionalEdgeInsets(
                top: Constants.sectionTopInset,
                leading: 0,
                bottom: Constants.sectionBottomInset,
                trailing: 0
            )

            if showsHeaders {
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(Constants.estimatedHeaderHeight)
                    ),
                    elementKind: sectionHeaderKind,
                    alignment: .top
                )
                header.pinToVisibleBounds = true
                section.boundarySupplementaryItems = [header]
            }
            return section
        }
    }

    /// How many cards of at least `minimumCardWidth` fit in `width`, with `spacing` between them.
    /// n cards need n * cardWidth + (n - 1) * spacing, so n = (width + spacing) / (cardWidth + spacing).
    nonisolated static func columnCount(for width: CGFloat, minimumCardWidth: CGFloat, spacing: CGFloat) -> Int {
        let fitting = Int((width + spacing) / (minimumCardWidth + spacing))
        return max(Constants.minimumColumns, fitting)
    }
}
