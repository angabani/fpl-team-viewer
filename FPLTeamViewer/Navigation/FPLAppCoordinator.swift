//
//  FPLAppCoordinator.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import UIKit

private enum Constants {
    static let primaryColumnWidthFraction: CGFloat = 0.36
    static let minimumPrimaryColumnWidth: CGFloat = 300
    static let maximumPrimaryColumnWidth: CGFloat = 420
}

// MARK: - FPLAppCoordinator

/// Builds screens and handles navigation.
///
/// Uses a split view so the app adapts on its own:
/// - Narrow width (iPhone, folded iPhone Duo): one column, push navigation.
/// - Wide width (unfolded iPhone Duo, iPad): teams on the left, squad on the right.
/// UIKit switches between the two when the size class changes, e.g. on fold or unfold.
@MainActor
final class FPLAppCoordinator: NSObject {
    private let dependencies: FPLAppDependencies
    private let splitViewController = UISplitViewController(style: .doubleColumn)
    private var selectedTeamID: Int?

    init(dependencies: FPLAppDependencies) {
        self.dependencies = dependencies
        super.init()
    }

    func start() -> UIViewController {
        let viewModel = FPLTeamsViewModel(repository: dependencies.repository)
        let teamsViewController = FPLTeamsViewController(viewModel: viewModel, navigator: self)

        splitViewController.setViewController(teamsViewController, for: .primary)
        splitViewController.setViewController(FPLPlaceholderViewController(), for: .secondary)
        splitViewController.preferredDisplayMode = .oneBesideSecondary
        splitViewController.preferredSplitBehavior = .tile
        splitViewController.preferredPrimaryColumnWidthFraction = Constants.primaryColumnWidthFraction
        splitViewController.minimumPrimaryColumnWidth = Constants.minimumPrimaryColumnWidth
        splitViewController.maximumPrimaryColumnWidth = Constants.maximumPrimaryColumnWidth
        splitViewController.delegate = self
        return splitViewController
    }
}

// MARK: - IFPLNavigator

extension FPLAppCoordinator: IFPLNavigator {
    func showSquad(for team: FPLTeam) {
        selectedTeamID = team.id
        let viewModel = FPLSquadViewModel(team: team, repository: dependencies.repository)
        let squadViewController = FPLSquadViewController(viewModel: viewModel)

        // Replaces the right column when wide, pushes when narrow.
        splitViewController.showDetailViewController(squadViewController, sender: self)
    }
}

// MARK: - UISplitViewControllerDelegate

extension FPLAppCoordinator: UISplitViewControllerDelegate {
    func splitViewController(
        _ svc: UISplitViewController,
        topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column
    ) -> UISplitViewController.Column {
        // When folding: keep the open squad on top. With no team picked, show the teams list.
        selectedTeamID == nil ? .primary : proposedTopColumn
    }
}
