//
//  FPLDecodingTests.swift
//  FPLTeamViewerTests
//
//  Created by AG on 29/09/26.
//

import Foundation
import Testing
@testable import FPLTeamViewer

struct FPLDecodingTests {
    @Test func decodesTeamsAndPlayersFromFixture() throws {
        let response = try Fixture.bootstrapResponse()

        #expect(response.teams.count == 3)
        #expect(response.elements.count == 9)

        let saka = try #require(response.elements.first { $0.id == 2 })
        #expect(saka.firstName == "Bukayo")
        #expect(saka.webName == "Saka")
        #expect(saka.team == 1)
        #expect(saka.elementType == 3)
        #expect(saka.nowCost == 101)
        #expect(saka.totalPoints == 120)

        let arsenal = try #require(response.teams.first { $0.id == 1 })
        #expect(arsenal.shortName == "ARS")
    }

    @Test func ignoresUnknownKeys() throws {
        let json = #"{"teams":[{"id":1,"name":"Arsenal","short_name":"ARS","new_field":true}],"elements":[],"extra":{}}"#
        let response = try FPLBootstrapResponse.decode(from: Data(json.utf8))
        #expect(response.teams.first?.name == "Arsenal")
    }

    @Test func failsWhenRequiredFieldIsMissing() {
        let json = #"{"teams":[{"id":1,"name":"Arsenal"}],"elements":[]}"#
        #expect(throws: DecodingError.self) {
            try FPLBootstrapResponse.decode(from: Data(json.utf8))
        }
    }

    @Test func failsOnInvalidJSON() {
        #expect(throws: (any Error).self) {
            try FPLBootstrapResponse.decode(from: Data("not json".utf8))
        }
    }
}
