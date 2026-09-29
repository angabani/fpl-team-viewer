//
//  FPLCardCell.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import UIKit

private enum Constants {
    static let selectedTintAlpha: CGFloat = 0.18
    static let badgeTintAlpha: CGFloat = 0.14
    static let badgeCornerRadius = FPLLayoutConstants.spacingS
    static let badgePadding = UIEdgeInsets(
        top: FPLLayoutConstants.spacingXS,
        left: FPLLayoutConstants.spacingS,
        bottom: FPLLayoutConstants.spacingXS,
        right: FPLLayoutConstants.spacingS
    )
}

// MARK: - FPLCardCell

/// Base cell with a rounded card background that reacts to tap and selection.
class FPLCardCell: UICollectionViewCell {
    override func updateConfiguration(using state: UICellConfigurationState) {
        var background = UIBackgroundConfiguration.clear()
        background.cornerRadius = FPLLayoutConstants.cardCornerRadius
        let gutter = FPLLayoutConstants.cardGutter
        background.backgroundInsets = NSDirectionalEdgeInsets(top: 0, leading: gutter, bottom: 0, trailing: gutter)
        if state.isSelected {
            background.backgroundColor = FPLColor.accent.withAlphaComponent(Constants.selectedTintAlpha)
        } else if state.isHighlighted {
            background.backgroundColor = .tertiarySystemFill
        } else {
            background.backgroundColor = .secondarySystemGroupedBackground
        }
        backgroundConfiguration = background
    }
}

// MARK: - FPLBadgeLabel

/// Small rounded tag, e.g. "ARS" or "MID".
final class FPLBadgeLabel: UILabel {
    private let padding = Constants.badgePadding

    init(textStyle: UIFont.TextStyle) {
        super.init(frame: .zero)
        font = UIFont.preferredFont(forTextStyle: textStyle).bold()
        adjustsFontForContentSizeCategory = true
        textAlignment = .center
        textColor = FPLColor.accent
        backgroundColor = FPLColor.accent.withAlphaComponent(Constants.badgeTintAlpha)
        layer.cornerRadius = Constants.badgeCornerRadius
        layer.cornerCurve = .continuous
        clipsToBounds = true
        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + padding.left + padding.right, height: size.height + padding.top + padding.bottom)
    }
}

// MARK: - UIFont

extension UIFont {
    func bold() -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(.traitBold) else { return self }
        return UIFont(descriptor: descriptor, size: 0)
    }
}
