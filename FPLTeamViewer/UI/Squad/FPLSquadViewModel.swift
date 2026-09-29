//
//  FPLSquadViewModel.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import Foundation

// MARK: - FPLSquadViewModel

/// Drives the squad screen. Starts with the team passed in, so it shows data instantly.
/// Pull to refresh fetches again and picks this team from the fresh data.
@MainActor
final class FPLSquadViewModel {
    // MARK: - Outputs

    var onStateChange: ((FPLViewState<[FPLSquadSection]>) -> Void)?
    var onRefreshError: ((String) -> Void)?

    private(set) var state: FPLViewState<[FPLSquadSection]> = .loading {
        didSet { onStateChange?(state) }
    }

    private(set) var team: FPLTeam
    private(set) var searchText = ""

    var title: String {
        team.name
    }

    // MARK: - Private

    private let repository: IFPLRepository
    private var isFetching = false

    init(team: FPLTeam, repository: IFPLRepository) {
        self.team = team
        self.repository = repository
        rebuildState()
    }

    // MARK: - Inputs

    /// Called on every keystroke. Filtering is local and fast, no debounce needed.
    func search(_ text: String) {
        guard text != searchText else { return }
        searchText = text
        rebuildState()
    }

    func refresh() async {
        guard !isFetching else { return }
        isFetching = true
        defer { isFetching = false }

        do {
            let snapshot = try await repository.fetchTeams()
            // If the team is gone from the API, show it as empty rather than old data.
            team = snapshot.teams.first { $0.id == team.id }
                ?? FPLTeam(id: team.id, name: team.name, shortName: team.shortName, players: [])
            rebuildState()
        } catch is CancellationError {
            return
        } catch {
            onRefreshError?(FPLStringKey.refreshFailed)
        }
    }

    // MARK: - Private

    private func rebuildState() {
        guard !team.players.isEmpty else {
            state = .empty(title: FPLStringKey.noPlayersTitle, message: FPLStringKey.noPlayersMessage)
            return
        }

        let players = FPLPlayerFilter.filter(team.players, query: searchText)
        let sections = FPLBootstrapMapper.squadSections(from: players)

        if sections.isEmpty {
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            state = .empty(title: FPLStringKey.noResultsTitle, message: FPLStringKey.noResultsMessage(query))
        } else {
            state = .loaded(sections)
        }
    }
}
