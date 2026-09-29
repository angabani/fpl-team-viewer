//
//  FPLBannerView.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import UIKit

private enum Constants {
    static let visibleDuration: Duration = .seconds(4)
    static let fadeDuration: TimeInterval = 0.25
    static let bottomMargin = FPLLayoutConstants.spacingM
    static let verticalPadding = FPLLayoutConstants.spacingM
    static let iconSpacing = FPLLayoutConstants.spacingS
    static let shadowOpacity: Float = 0.15
    static let shadowRadius: CGFloat = 10
    static let shadowOffset = CGSize(width: 0, height: 4)
}

// MARK: - FPLBannerView

/// Small message at the bottom of the screen. Hides itself after a few seconds.
/// Used for refresh errors, where data must stay on screen.
final class FPLBannerView: UIView {
    private let iconView = UIImageView(image: UIImage(systemName: FPLImageName.warning))
    private let messageLabel = UILabel()
    private var hideTask: Task<Void, Never>?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(_ message: String, in container: UIView) {
        if superview == nil {
            container.addSubview(self)
            NSLayoutConstraint.activate([
                leadingAnchor.constraint(equalTo: container.readableContentGuide.leadingAnchor),
                trailingAnchor.constraint(equalTo: container.readableContentGuide.trailingAnchor),
                bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.bottomMargin)
            ])
        }
        container.bringSubviewToFront(self)
        messageLabel.text = message
        UIAccessibility.post(notification: .announcement, argument: message)

        UIView.animate(withDuration: Constants.fadeDuration) { self.alpha = 1 }

        hideTask?.cancel()
        hideTask = Task { [weak self] in
            try? await Task.sleep(for: Constants.visibleDuration)
            guard !Task.isCancelled else { return }
            UIView.animate(withDuration: Constants.fadeDuration) { self?.alpha = 0 }
        }
    }

    // MARK: - Setup

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        alpha = 0
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = FPLLayoutConstants.cardCornerRadius
        layer.cornerCurve = .continuous
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = Constants.shadowOpacity
        layer.shadowRadius = Constants.shadowRadius
        layer.shadowOffset = Constants.shadowOffset

        iconView.tintColor = .systemOrange
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .subheadline)

        messageLabel.font = .preferredFont(forTextStyle: .subheadline)
        messageLabel.adjustsFontForContentSizeCategory = true
        messageLabel.numberOfLines = 0

        let stackView = UIStackView(arrangedSubviews: [iconView, messageLabel])
        stackView.spacing = Constants.iconSpacing
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        let padding = FPLLayoutConstants.cardPadding
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.verticalPadding),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.verticalPadding),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding)
        ])
    }
}
