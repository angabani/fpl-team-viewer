//
//  UIContentUnavailableConfiguration+FPL.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import UIKit

extension UIContentUnavailableConfiguration {
    /// Maps a view state to the system loading / empty / error view.
    /// Returns nil when there is data, so the list is shown.
    @MainActor
    static func fpl<Content>(
        state: FPLViewState<Content>,
        emptyImageName: String,
        emptyAction: (@MainActor () -> Void)? = nil,
        retry: @escaping @MainActor () -> Void
    ) -> UIContentUnavailableConfiguration? {
        switch state {
        case .loaded:
            return nil

        case .loading:
            var configuration = UIContentUnavailableConfiguration.loading()
            configuration.text = FPLStringKey.loadingTeams
            return configuration

        case .empty(let title, let message):
            var configuration = UIContentUnavailableConfiguration.empty()
            configuration.image = UIImage(systemName: emptyImageName)
            configuration.text = title
            configuration.secondaryText = message
            if let emptyAction {
                configuration.button = .borderedTinted()
                configuration.button.title = FPLStringKey.reload
                configuration.buttonProperties.primaryAction = UIAction { _ in emptyAction() }
            }
            return configuration

        case .failed(let message):
            var configuration = UIContentUnavailableConfiguration.empty()
            configuration.image = UIImage(systemName: FPLImageName.error)
            configuration.text = FPLStringKey.errorTitle
            configuration.secondaryText = message
            configuration.button = .filled()
            configuration.button.title = FPLStringKey.retry
            configuration.buttonProperties.primaryAction = UIAction { _ in retry() }
            return configuration
        }
    }
}
