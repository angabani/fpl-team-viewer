//
//  FPLTeamsViewModel.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import Foundation

// MARK: - FPLTeamsViewModel

/// Drives the teams screen. No UIKit here, so it is fully unit testable.
///
/// Flow:
/// 1. Show cached teams right away if we have them.
/// 2. Fetch fresh teams from the API.
/// 3. If the fetch fails and something is on screen, keep it and report a refresh error.
///    If nothing is on screen, show the error state with Retry.
@MainActor
final class FPLTeamsViewModel {
    // MARK: - Outputs

    var onStateChange: ((FPLViewState<[FPLTeam]>) -> Void)?
    var onRefreshError: ((String) -> Void)?
    /// True while a network request is running, even when data is already on screen.
    var onFetchingChange: ((Bool) -> Void)?

    private(set) var state: FPLViewState<[FPLTeam]> = .loading {
        didSet { onStateChange?(state) }
    }

    private(set) var lastUpdated: Date?

    private(set) var isFetching = false {
        didSet { onFetchingChange?(isFetching) }
    }

    // MARK: - Private

    private let repository: IFPLRepository
    private var snapshot: FPLTeamsSnapshot?

    init(repository: IFPLRepository) {
        self.repository = repository
    }

    // MARK: - Inputs

    /// First load. Also used by Retry.
    func load() async {
        guard !isFetching else { return }

        if snapshot == nil {
            if let cached = await repository.loadCachedTeams() {
                apply(cached)
            } else {
                state = .loading
            }
        }
        await fetch()
    }

    /// Pull to refresh.
    func refresh() async {
        await fetch()
    }

    // MARK: - Private

    private func fetch() async {
        // Avoid two requests racing each other, e.g. retry tapped during a refresh.
        guard !isFetching else { return }
        isFetching = true
        defer { isFetching = false }

        do {
            apply(try await repository.fetchTeams())
        } catch is CancellationError {
            return
        } catch {
            handle(error)
        }
    }

    private func apply(_ snapshot: FPLTeamsSnapshot) {
        self.snapshot = snapshot
        lastUpdated = snapshot.updatedAt
        state = snapshot.teams.isEmpty
            ? .empty(title: FPLStringKey.noTeamsTitle, message: FPLStringKey.noTeamsMessage)
            : .loaded(snapshot.teams)
    }

    private func handle(_ error: Error) {
        if snapshot != nil {
            // Keep what the user is looking at.
            onRefreshError?(FPLStringKey.refreshFailed)
        } else {
            state = .failed(message: error.fplMessage)
        }
    }
}
