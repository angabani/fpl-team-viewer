//
//  FPLPlayerFilterTests.swift
//  FPLTeamViewerTests
//
//  Created by AG on 29/09/26.
//

import Foundation
import Testing
@testable import FPLTeamViewer

struct FPLPlayerFilterTests {
    private let players = [
        Fixture.player(id: 1, webName: "Saka", firstName: "Bukayo", secondName: "Saka"),
        Fixture.player(id: 2, webName: "Raya", firstName: "David", secondName: "Raya Martín"),
        Fixture.player(id: 3, webName: "Rice", firstName: "Declan", secondName: "Rice")
    ]

    @Test func emptyQueryReturnsAllPlayers() {
        #expect(FPLPlayerFilter.filter(players, query: "").count == 3)
        #expect(FPLPlayerFilter.filter(players, query: "   ").count == 3)
    }

    @Test func matchesShortNameIgnoringCase() {
        #expect(FPLPlayerFilter.filter(players, query: "SAKA").map(\.id) == [1])
    }

    @Test func matchesPartOfTheName() {
        #expect(FPLPlayerFilter.filter(players, query: "ra").map(\.id) == [2])
        #expect(FPLPlayerFilter.filter(players, query: "R").map(\.id) == [2, 3])
    }

    @Test func matchesFirstNameAndFullName() {
        #expect(FPLPlayerFilter.filter(players, query: "declan").map(\.id) == [3])
        #expect(FPLPlayerFilter.filter(players, query: "bukayo saka").map(\.id) == [1])
    }

    @Test func ignoresAccents() {
        #expect(FPLPlayerFilter.filter(players, query: "martin").map(\.id) == [2])
        #expect(FPLPlayerFilter.filter(players, query: "Martín").map(\.id) == [2])
    }

    @Test func trimsSpaces() {
        #expect(FPLPlayerFilter.filter(players, query: "  rice ").map(\.id) == [3])
    }

    @Test func noMatchReturnsEmpty() {
        #expect(FPLPlayerFilter.filter(players, query: "haaland").isEmpty)
    }
}
