//
//  FPLModelTests.swift
//  FPLTeamViewerTests
//
//  Created by AG on 29/09/26.
//

import Foundation
import Testing
@testable import FPLTeamViewer

/// Small model and helper behaviour used by the screens.
struct FPLModelTests {
    // MARK: - Position

    @Test func positionsHaveTitlesAndShortNames() {
        #expect(FPLPosition.allCases.map(\.title) == [
            FPLStringKey.goalkeepers, FPLStringKey.defenders, FPLStringKey.midfielders, FPLStringKey.forwards
        ])
        #expect(FPLPosition.allCases.map(\.shortName) == ["GKP", "DEF", "MID", "FWD"])
    }

    @Test func positionRawValuesMatchAPI() {
        #expect(FPLPosition(rawValue: 1) == .goalkeeper)
        #expect(FPLPosition(rawValue: 4) == .forward)
        #expect(FPLPosition(rawValue: 5) == nil)
    }

    // MARK: - Player

    @Test func playerTextHelpers() {
        let player = FPLPlayer(
            id: 1,
            firstName: "Bukayo",
            secondName: "Saka",
            webName: "Saka",
            teamID: 1,
            position: .midfielder,
            nowCost: 101,
            totalPoints: 120,
            status: .available,
            news: "",
            form: 7.1,
            selectedByPercent: 42.3
        )
        #expect(player.priceText == "£10.1m")
        #expect(player.statsText == FPLStringKey.playerStats(form: "7.1", selectedByPercent: "42.3"))
    }

    @Test func pointsAndPlayerCountUseSingularForOne() {
        #expect(FPLStringKey.points(1) == "1 pt")
        #expect(FPLStringKey.points(2) == "2 pts")
        #expect(FPLStringKey.playerCount(1) == "1 player")
        #expect(FPLStringKey.playerCount(29) == "29 players")
    }

    // MARK: - View state

    @Test func viewStateContentOnlyWhenLoaded() {
        #expect(FPLViewState<[Int]>.loaded([1, 2]).content == [1, 2])
        #expect(FPLViewState<[Int]>.loading.content == nil)
        #expect(FPLViewState<[Int]>.failed(message: "x").content == nil)
        #expect(FPLViewState<[Int]>.empty(title: "t", message: "m").content == nil)
    }

    // MARK: - Helpers

    @Test func safeSubscriptReturnsNilOutOfRange() {
        let values = [10, 20]
        #expect(values[safe: 1] == 20)
        #expect(values[safe: 2] == nil)
        #expect(values[safe: -1] == nil)
    }

    @Test func lastUpdatedTextIncludesTheDate() {
        let date = Date(timeIntervalSince1970: 0)
        #expect(FPLStringKey.lastUpdated(date).contains(date.fplShortText))
        #expect(!date.fplShortText.isEmpty)
    }
}
