//
//  FPLInsightTests.swift
//  FPLTeamViewerTests
//
//  Created by AG on 29/09/26.
//

import Foundation
import Testing
@testable import FPLTeamViewer

/// Extra info shown on cards: squad value, top player, form, ownership, availability.
struct FPLInsightTests {
    // MARK: - Team

    @Test func squadValueIsSumOfPrices() {
        let team = FPLTeam(id: 1, name: "Team", shortName: "TEA", players: [
            Fixture.player(id: 1, webName: "A", nowCost: 61),
            Fixture.player(id: 2, webName: "B", nowCost: 100)
        ])
        #expect(team.squadValue == 161)
        #expect(team.squadValue.fplPriceText == "£16.1m")
    }

    @Test func topPlayerHasMostPointsAndNameBreaksTies() {
        let team = FPLTeam(id: 1, name: "Team", shortName: "TEA", players: [
            Fixture.player(id: 1, webName: "Saka", totalPoints: 120),
            Fixture.player(id: 2, webName: "Rice", totalPoints: 120),
            Fixture.player(id: 3, webName: "Raya", totalPoints: 30)
        ])
        #expect(team.topPlayer?.webName == "Rice")
    }

    @Test func noTopPlayerBeforeAnyoneScores() {
        let team = FPLTeam(id: 1, name: "Team", shortName: "TEA", players: [
            Fixture.player(id: 1, webName: "A", totalPoints: 0)
        ])
        #expect(team.topPlayer == nil)
        #expect(team.insightText == FPLStringKey.squadValue(team.squadValue.fplPriceText))
    }

    @Test func insightTextShowsValueAndTopPlayer() throws {
        let arsenal = try #require(try Fixture.teams().first { $0.shortName == "ARS" })
        let expected = FPLStringKey.squadValue(arsenal.squadValue.fplPriceText)
            + FPLStringKey.separator
            + FPLStringKey.topPlayer(name: "Rice", points: 120)
        #expect(arsenal.insightText == expected)
    }

    // MARK: - Player

    @Test func mapsStatusFormOwnershipAndNews() throws {
        let players = try Fixture.teams().flatMap(\.players)
        let saka = try #require(players.first { $0.webName == "Saka" })
        let odegaard = try #require(players.first { $0.webName == "Ødegaard" })
        let havertz = try #require(players.first { $0.webName == "Havertz" })

        #expect(saka.status == .available)
        #expect(saka.form == 7.1)
        #expect(saka.selectedByPercent == 42.3)
        #expect(saka.availabilityText == nil)

        #expect(odegaard.status == .doubtful)
        #expect(odegaard.availabilityText == "Knee injury - 75% chance of playing")

        // No news text, so the status name is shown.
        #expect(havertz.status == .injured)
        #expect(havertz.availabilityText == FPLStringKey.statusInjured)
    }

    @Test func missingOptionalFieldsUseSafeDefaults() throws {
        let raya = try #require(try Fixture.teams().flatMap(\.players).first { $0.webName == "Raya" })
        #expect(raya.selectedByPercent == 0)
        #expect(raya.news.isEmpty)
    }

    @Test(arguments: [
        ("a", FPLPlayerStatus.available),
        ("d", .doubtful),
        ("i", .injured),
        ("s", .suspended),
        ("u", .unavailable),
        ("n", .notInSquad),
        ("x", .available)
    ])
    func statusCodeMapping(code: String, expected: FPLPlayerStatus) {
        #expect(FPLPlayerStatus(code: code) == expected)
    }

    @Test func missingStatusCountsAsAvailable() {
        #expect(FPLPlayerStatus(code: nil) == .available)
    }

    @Test func onlyDoubtfulIsAWarning() {
        #expect(FPLPlayerStatus.doubtful.isWarning)
        #expect(!FPLPlayerStatus.injured.isWarning)
        #expect(!FPLPlayerStatus.suspended.isWarning)
    }

    @Test func oneDecimalFormatting() {
        #expect(6.0.fplOneDecimalText == "6.0")
        #expect(42.34.fplOneDecimalText == "42.3")
    }
}
