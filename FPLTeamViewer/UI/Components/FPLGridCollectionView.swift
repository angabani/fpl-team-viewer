//
//  FPLGridCollectionView.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import UIKit

// MARK: - FPLGridCollectionView

/// Collection view for the card grid.
/// Cards size themselves to their text. When the usable width changes (margins settling on
/// first layout, rotation, split view resize, fold/unfold) they must be measured again,
/// otherwise a line that now needs to wrap gets cut off.
final class FPLGridCollectionView: UICollectionView {
    private var lastUsableWidth: CGFloat = 0

    override func layoutSubviews() {
        let usableWidth = bounds.width - layoutMargins.left - layoutMargins.right
        if usableWidth != lastUsableWidth {
            lastUsableWidth = usableWidth
            collectionViewLayout.invalidateLayout()
        }
        super.layoutSubviews()
    }
}
