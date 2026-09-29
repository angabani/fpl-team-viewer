//
//  FPLSquadViewModelTests.swift
//  FPLTeamViewerTests
//
//  Created by AG on 29/09/26.
//

import Foundation
import Testing
@testable import FPLTeamViewer

@MainActor
struct FPLSquadViewModelTests {
    private func arsenal() throws -> FPLTeam {
        try #require(try Fixture.teams().first { $0.shortName == "ARS" })
    }

    @Test func showsPlayersGroupedByPositionRightAway() throws {
        let viewModel = FPLSquadViewModel(team: try arsenal(), repository: MockFPLRepository())

        let sections = try #require(viewModel.state.content)
        #expect(sections.map(\.position) == [.goalkeeper, .defender, .midfielder, .forward])
        #expect(viewModel.title == "Arsenal")
    }

    @Test func searchFiltersPlayersAsYouType() throws {
        let viewModel = FPLSquadViewModel(team: try arsenal(), repository: MockFPLRepository())

        viewModel.search("s")
        let afterS = try #require(viewModel.state.content).flatMap(\.players).map(\.webName)
        #expect(afterS.contains("Saka"))

        viewModel.search("sak")
        let sections = try #require(viewModel.state.content)
        #expect(sections.map(\.position) == [.midfielder])
        #expect(sections.first?.players.map(\.webName) == ["Saka"])
    }

    @Test func clearingSearchShowsEveryone() throws {
        let team = try arsenal()
        let viewModel = FPLSquadViewModel(team: team, repository: MockFPLRepository())

        viewModel.search("saka")
        viewModel.search("")

        let count = try #require(viewModel.state.content).flatMap(\.players).count
        #expect(count == team.playerCount)
    }

    @Test func searchWithNoMatchShowsEmptyState() throws {
        let viewModel = FPLSquadViewModel(team: try arsenal(), repository: MockFPLRepository())

        viewModel.search("haaland")

        #expect(viewModel.state == .empty(
            title: FPLStringKey.noResultsTitle,
            message: FPLStringKey.noResultsMessage("haaland")
        ))
    }

    @Test func teamWithoutPlayersShowsEmptyState() throws {
        let chelsea = try #require(try Fixture.teams().first { $0.shortName == "CHE" })
        let viewModel = FPLSquadViewModel(team: chelsea, repository: MockFPLRepository())

        #expect(viewModel.state == .empty(title: FPLStringKey.noPlayersTitle, message: FPLStringKey.noPlayersMessage))
    }

    @Test func refreshFailureKeepsPlayersAndReportsError() async throws {
        let viewModel = FPLSquadViewModel(
            team: try arsenal(),
            repository: MockFPLRepository(fetchResults: [.failure(FPLNetworkError.noInternet)])
        )
        let before = viewModel.state
        var refreshError: String?
        viewModel.onRefreshError = { refreshError = $0 }

        await viewModel.refresh()

        #expect(viewModel.state == before)
        #expect(refreshError == FPLStringKey.refreshFailed)
    }

    @Test func refreshKeepsSearchText() async throws {
        let team = try arsenal()
        let viewModel = FPLSquadViewModel(
            team: team,
            repository: MockFPLRepository(fetchResults: [.success(Fixture.snapshot(try Fixture.teams()))])
        )
        viewModel.search("rice")

        await viewModel.refresh()

        #expect(try #require(viewModel.state.content).flatMap(\.players).map(\.webName) == ["Rice"])
    }

    @Test func refreshUpdatesPlayersFromFreshData() async throws {
        let team = try arsenal()
        let updated = FPLTeam(id: team.id, name: team.name, shortName: team.shortName, players: Array(team.players.prefix(1)))
        let viewModel = FPLSquadViewModel(
            team: team,
            repository: MockFPLRepository(fetchResults: [.success(Fixture.snapshot([updated]))])
        )

        await viewModel.refresh()

        #expect(try #require(viewModel.state.content).flatMap(\.players).count == 1)
    }
}
