//
//  FPLTeamCell.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import UIKit

private enum Constants {
    static let badgeMinWidth: CGFloat = 56
    static let verticalPadding = FPLLayoutConstants.spacingM
}

// MARK: - FPLTeamCell

final class FPLTeamCell: FPLCardCell {
    static let reuseIdentifier = String(describing: FPLTeamCell.self)

    private let badgeLabel = FPLBadgeLabel(textStyle: .footnote)
    private let nameLabel = UILabel()
    private let detailLabel = UILabel()
    private let insightLabel = UILabel()
    private let chevronView = UIImageView(image: UIImage(systemName: FPLImageName.chevron))

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with team: FPLTeam) {
        badgeLabel.text = team.shortName
        nameLabel.text = team.name
        detailLabel.text = FPLStringKey.teamDetail(shortName: team.shortName, playerCount: team.playerCount)
        insightLabel.text = team.insightText

        isAccessibilityElement = true
        accessibilityLabel = FPLStringKey.teamAccessibility(
            name: team.name,
            playerCount: team.playerCount,
            extra: team.insightText
        )
        accessibilityTraits = .button
    }

    // MARK: - Setup

    private func setupView() {
        nameLabel.font = .preferredFont(forTextStyle: .headline)
        nameLabel.adjustsFontForContentSizeCategory = true
        nameLabel.numberOfLines = 0

        detailLabel.font = .preferredFont(forTextStyle: .subheadline)
        detailLabel.adjustsFontForContentSizeCategory = true
        detailLabel.textColor = .secondaryLabel
        detailLabel.numberOfLines = 0

        insightLabel.font = .preferredFont(forTextStyle: .footnote)
        insightLabel.adjustsFontForContentSizeCategory = true
        insightLabel.textColor = FPLColor.accent
        insightLabel.numberOfLines = 0

        chevronView.tintColor = .tertiaryLabel
        chevronView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .footnote, scale: .medium)
        chevronView.setContentHuggingPriority(.required, for: .horizontal)

        badgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: Constants.badgeMinWidth).isActive = true

        let textStack = UIStackView(arrangedSubviews: [nameLabel, detailLabel, insightLabel])
        textStack.axis = .vertical
        textStack.spacing = FPLLayoutConstants.labelSpacing

        let rowStack = UIStackView(arrangedSubviews: [badgeLabel, textStack, chevronView])
        rowStack.spacing = FPLLayoutConstants.contentSpacing
        rowStack.alignment = .center
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rowStack)

        let padding = FPLLayoutConstants.cardPadding + FPLLayoutConstants.cardGutter
        NSLayoutConstraint.activate([
            rowStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.verticalPadding),
            rowStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.verticalPadding),
            rowStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            rowStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)
        ])
    }
}
