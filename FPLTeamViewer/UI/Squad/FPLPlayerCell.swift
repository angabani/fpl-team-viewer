//
//  FPLPlayerCell.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import UIKit

private enum Constants {
    static let verticalPadding = FPLLayoutConstants.spacingM
}

// MARK: - FPLPlayerCell

final class FPLPlayerCell: FPLCardCell {
    static let reuseIdentifier = String(describing: FPLPlayerCell.self)

    private let positionLabel = FPLBadgeLabel(textStyle: .caption1)
    private let nameLabel = UILabel()
    private let fullNameLabel = UILabel()
    private let statsLabel = UILabel()
    private let availabilityLabel = UILabel()
    private let priceLabel = UILabel()
    private let pointsLabel = UILabel()
    private let rowStack = UIStackView()
    private let valueStack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (cell: FPLPlayerCell, _) in
            cell.updateAxisForContentSize()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with player: FPLPlayer) {
        positionLabel.text = player.position.shortName
        nameLabel.text = player.webName
        fullNameLabel.text = player.fullName
        fullNameLabel.isHidden = player.fullName == player.webName
        priceLabel.text = player.priceText
        pointsLabel.text = FPLStringKey.points(player.totalPoints)
        statsLabel.text = player.statsText

        availabilityLabel.text = player.availabilityText
        availabilityLabel.isHidden = player.availabilityText == nil
        availabilityLabel.textColor = player.status.isWarning ? FPLColor.warning : FPLColor.critical

        isAccessibilityElement = true
        accessibilityLabel = FPLStringKey.playerAccessibility(
            fullName: player.fullName,
            position: player.position.title,
            price: player.priceText,
            points: player.totalPoints,
            stats: player.statsText,
            availability: player.availabilityText
        )
    }

    // MARK: - Setup

    private func setupView() {
        nameLabel.font = .preferredFont(forTextStyle: .headline)
        fullNameLabel.font = .preferredFont(forTextStyle: .footnote)
        fullNameLabel.textColor = .secondaryLabel
        priceLabel.font = .preferredFont(forTextStyle: .subheadline).bold()
        pointsLabel.font = .preferredFont(forTextStyle: .footnote)
        pointsLabel.textColor = .secondaryLabel
        statsLabel.font = .preferredFont(forTextStyle: .caption1)
        statsLabel.textColor = .secondaryLabel
        availabilityLabel.font = .preferredFont(forTextStyle: .caption1).bold()

        [nameLabel, fullNameLabel, statsLabel, availabilityLabel, priceLabel, pointsLabel].forEach {
            $0.adjustsFontForContentSizeCategory = true
        }
        // Name lines can wrap. Price and points are short and stay on one line:
        // a multi-line label has no fixed natural width, so it would not hug and
        // the value column would take space from the name.
        [nameLabel, fullNameLabel, statsLabel, availabilityLabel].forEach {
            $0.numberOfLines = 0
        }

        // Price and points keep their natural width, the name column takes the rest.
        [priceLabel, pointsLabel].forEach {
            $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        }

        let nameStack = UIStackView(arrangedSubviews: [nameLabel, fullNameLabel, statsLabel, availabilityLabel])
        nameStack.axis = .vertical
        nameStack.spacing = FPLLayoutConstants.labelSpacing

        valueStack.addArrangedSubview(priceLabel)
        valueStack.addArrangedSubview(pointsLabel)
        valueStack.axis = .vertical
        // Fill, not trailing: with trailing the column can grow wider than its text.
        // Right alignment comes from the labels.
        valueStack.alignment = .fill
        valueStack.spacing = FPLLayoutConstants.labelSpacing

        rowStack.addArrangedSubview(positionLabel)
        rowStack.addArrangedSubview(nameStack)
        rowStack.addArrangedSubview(valueStack)
        rowStack.spacing = FPLLayoutConstants.contentSpacing
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rowStack)

        let padding = FPLLayoutConstants.cardPadding + FPLLayoutConstants.cardGutter
        NSLayoutConstraint.activate([
            rowStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.verticalPadding),
            rowStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.verticalPadding),
            rowStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            rowStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)
        ])
        updateAxisForContentSize()
    }

    /// With very large text, stack vertically so nothing gets cut.
    private func updateAxisForContentSize() {
        let isLarge = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        rowStack.axis = isLarge ? .vertical : .horizontal
        rowStack.alignment = isLarge ? .leading : .center
        priceLabel.textAlignment = isLarge ? .natural : .right
        pointsLabel.textAlignment = isLarge ? .natural : .right
    }
}
