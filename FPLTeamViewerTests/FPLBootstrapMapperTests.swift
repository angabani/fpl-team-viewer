//
//  FPLBootstrapMapperTests.swift
//  FPLTeamViewerTests
//
//  Created by AG on 29/09/26.
//

import Foundation
import Testing
@testable import FPLTeamViewer

struct FPLBootstrapMapperTests {
    @Test func teamsAreSortedByName() throws {
        let teams = try Fixture.teams()
        #expect(teams.map(\.name) == ["Arsenal", "Aston Villa", "Chelsea"])
    }

    @Test func playersAreAttachedToTheirTeam() throws {
        let teams = try Fixture.teams()
        let counts = Dictionary(uniqueKeysWithValues: teams.map { ($0.shortName, $0.playerCount) })

        // Arsenal has 7 elements in the fixture, one is a manager (element_type 5) and is skipped.
        #expect(counts == ["ARS": 6, "AVL": 2, "CHE": 0])
    }

    @Test func unknownPositionIsSkipped() throws {
        let response = try Fixture.bootstrapResponse()
        let manager = try #require(response.elements.first { $0.elementType == 5 })
        #expect(FPLBootstrapMapper.player(from: manager) == nil)
    }

    @Test func sectionsFollowPositionOrderAndSkipEmptyOnes() {
        let players = [
            Fixture.player(id: 1, webName: "Fwd", position: .forward),
            Fixture.player(id: 2, webName: "Gk", position: .goalkeeper),
            Fixture.player(id: 3, webName: "Mid", position: .midfielder)
        ]

        let sections = FPLBootstrapMapper.squadSections(from: players)

        #expect(sections.map(\.position) == [.goalkeeper, .midfielder, .forward])
    }

    @Test func playersAreSortedByPointsThenName() throws {
        let arsenal = try #require(try Fixture.teams().first { $0.shortName == "ARS" })

        let sections = FPLBootstrapMapper.squadSections(from: arsenal.players)
        let midfielders = try #require(sections.first { $0.position == .midfielder })

        // Rice and Saka both have 120, so name decides.
        #expect(midfielders.players.map(\.webName) == ["Rice", "Saka", "Ødegaard"])
    }

    @Test func emptyPlayersGiveNoSections() {
        #expect(FPLBootstrapMapper.squadSections(from: []).isEmpty)
    }

    @Test func priceIsFormattedInMillions() {
        #expect(61.fplPriceText == "£6.1m")
        #expect(100.fplPriceText == "£10.0m")
        #expect(45.fplPriceText == "£4.5m")
    }

    @Test func fullNameJoinsFirstAndSecondName() {
        let player = Fixture.player(id: 1, webName: "Saka", firstName: "Bukayo", secondName: "Saka")
        #expect(player.fullName == "Bukayo Saka")
    }
}
