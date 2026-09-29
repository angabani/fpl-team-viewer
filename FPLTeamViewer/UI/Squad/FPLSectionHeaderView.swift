//
//  FPLSectionHeaderView.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import UIKit

private enum Constants {
    static let topPadding = FPLLayoutConstants.spacingM
    static let bottomPadding = FPLLayoutConstants.spacingS
    static let titleSpacing = FPLLayoutConstants.spacingS
}

// MARK: - FPLSectionHeaderView

/// Position header on the squad screen, e.g. "Defenders  8".
final class FPLSectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = String(describing: FPLSectionHeaderView.self)

    private let titleLabel = UILabel()
    private let countLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with section: FPLSquadSection) {
        titleLabel.text = section.position.title
        countLabel.text = "\(section.players.count)"
        accessibilityLabel = FPLStringKey.sectionAccessibility(title: section.position.title, playerCount: section.players.count)
    }

    // MARK: - Setup

    private func setupView() {
        backgroundColor = .systemGroupedBackground
        isAccessibilityElement = true
        accessibilityTraits = .header

        titleLabel.font = .preferredFont(forTextStyle: .title3).bold()
        titleLabel.adjustsFontForContentSizeCategory = true
        countLabel.font = .preferredFont(forTextStyle: .subheadline)
        countLabel.adjustsFontForContentSizeCategory = true
        countLabel.textColor = .secondaryLabel

        let stackView = UIStackView(arrangedSubviews: [titleLabel, countLabel, UIView()])
        stackView.spacing = Constants.titleSpacing
        stackView.alignment = .firstBaseline
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.topPadding),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.bottomPadding),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: FPLLayoutConstants.cardGutter),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -FPLLayoutConstants.cardGutter)
        ])
    }
}
