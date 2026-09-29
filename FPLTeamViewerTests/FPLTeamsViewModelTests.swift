//
//  FPLTeamsViewModelTests.swift
//  FPLTeamViewerTests
//
//  Created by AG on 29/09/26.
//

import Foundation
import Testing
@testable import FPLTeamViewer

@MainActor
struct FPLTeamsViewModelTests {
    @Test func startsInLoadingState() {
        let viewModel = FPLTeamsViewModel(repository: MockFPLRepository())
        #expect(viewModel.state == .loading)
    }

    @Test func successfulLoadShowsTeams() async throws {
        let teams = try Fixture.teams()
        let viewModel = FPLTeamsViewModel(repository: MockFPLRepository(fetchResults: [.success(Fixture.snapshot(teams))]))

        await viewModel.load()

        #expect(viewModel.state == .loaded(teams))
    }

    @Test func initialFailureShowsErrorThenRetryWorks() async throws {
        let teams = try Fixture.teams()
        let repository = MockFPLRepository(fetchResults: [
            .failure(FPLNetworkError.noInternet),
            .success(Fixture.snapshot(teams))
        ])
        let viewModel = FPLTeamsViewModel(repository: repository)

        await viewModel.load()
        #expect(viewModel.state == .failed(message: FPLNetworkError.noInternet.message))

        await viewModel.load()
        #expect(viewModel.state == .loaded(teams))
        #expect(repository.fetchCount == 2)
    }

    @Test func refreshFailureKeepsDataAndReportsError() async throws {
        let teams = try Fixture.teams()
        let repository = MockFPLRepository(fetchResults: [
            .success(Fixture.snapshot(teams)),
            .failure(FPLNetworkError.timeout)
        ])
        let viewModel = FPLTeamsViewModel(repository: repository)
        var refreshError: String?
        viewModel.onRefreshError = { refreshError = $0 }

        await viewModel.load()
        await viewModel.refresh()

        #expect(viewModel.state == .loaded(teams))
        #expect(refreshError == FPLStringKey.refreshFailed)
    }

    @Test func refreshSuccessUpdatesData() async throws {
        let teams = try Fixture.teams()
        let fewerTeams = Array(teams.prefix(1))
        let repository = MockFPLRepository(fetchResults: [
            .success(Fixture.snapshot(teams)),
            .success(Fixture.snapshot(fewerTeams, at: Date(timeIntervalSince1970: 99)))
        ])
        let viewModel = FPLTeamsViewModel(repository: repository)

        await viewModel.load()
        await viewModel.refresh()

        #expect(viewModel.state == .loaded(fewerTeams))
        #expect(viewModel.lastUpdated == Date(timeIntervalSince1970: 99))
    }

    @Test func offlineLaunchShowsCachedData() async throws {
        let teams = try Fixture.teams()
        let cachedAt = Date(timeIntervalSince1970: 42)
        let repository = MockFPLRepository(
            cached: Fixture.snapshot(teams, at: cachedAt),
            fetchResults: [.failure(FPLNetworkError.noInternet)]
        )
        let viewModel = FPLTeamsViewModel(repository: repository)
        var refreshError: String?
        viewModel.onRefreshError = { refreshError = $0 }

        await viewModel.load()

        #expect(viewModel.state == .loaded(teams))
        #expect(viewModel.lastUpdated == cachedAt)
        #expect(refreshError != nil)
    }

    @Test func cachedDataIsShownBeforeNetworkReturns() async throws {
        let teams = try Fixture.teams()
        let repository = MockFPLRepository(
            cached: Fixture.snapshot(teams),
            fetchResults: [.success(Fixture.snapshot(teams))]
        )
        let viewModel = FPLTeamsViewModel(repository: repository)
        var states: [FPLViewState<[FPLTeam]>] = []
        viewModel.onStateChange = { states.append($0) }

        await viewModel.load()

        // First the cache, then the fresh data. Never a loading spinner in between.
        #expect(states == [.loaded(teams), .loaded(teams)])
    }

    @Test func reportsFetchingWhileRequestRuns() async throws {
        let teams = try Fixture.teams()
        let repository = MockFPLRepository(
            cached: Fixture.snapshot(teams),
            fetchResults: [.success(Fixture.snapshot(teams))]
        )
        let viewModel = FPLTeamsViewModel(repository: repository)
        var fetchingChanges: [Bool] = []
        viewModel.onFetchingChange = { fetchingChanges.append($0) }

        await viewModel.load()

        #expect(fetchingChanges == [true, false])
        #expect(viewModel.isFetching == false)
    }

    @Test func noTeamsShowsEmptyState() async {
        let viewModel = FPLTeamsViewModel(repository: MockFPLRepository(fetchResults: [.success(Fixture.snapshot([]))]))

        await viewModel.load()

        #expect(viewModel.state == .empty(title: FPLStringKey.noTeamsTitle, message: FPLStringKey.noTeamsMessage))
    }

    @Test func cancelledRequestDoesNotShowError() async {
        let viewModel = FPLTeamsViewModel(repository: MockFPLRepository(fetchResults: [.failure(CancellationError())]))

        await viewModel.load()

        #expect(viewModel.state == .loading)
    }
}
