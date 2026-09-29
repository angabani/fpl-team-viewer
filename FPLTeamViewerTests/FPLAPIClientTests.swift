//
//  FPLAPIClientTests.swift
//  FPLTeamViewerTests
//
//  Created by AG on 29/09/26.
//

import Foundation
import Testing
@testable import FPLTeamViewer

/// Serialized because the URLProtocol stub uses a shared handler.
@Suite(.serialized)
struct FPLAPIClientTests {
    private let client = FPLAPIClient(session: URLProtocolStub.makeSession())

    @Test func returnsBodyOnSuccess() async throws {
        let body = Data("ok".utf8)
        URLProtocolStub.handler = { request in
            #expect(request.url?.absoluteString == URLConstants.bootstrapStatic)
            #expect(request.httpMethod == "GET")
            return (try URLProtocolStub.response(status: 200, for: request), body)
        }

        let data = try await client.send(FPLBootstrapNetworkRequest())
        #expect(data == body)
    }

    @Test(arguments: [404, 500, 503])
    func throwsBadStatusForNon2xx(status: Int) async {
        URLProtocolStub.handler = { request in
            (try URLProtocolStub.response(status: status, for: request), Data())
        }

        await #expect(throws: FPLNetworkError.badStatus(status)) {
            try await client.send(FPLBootstrapNetworkRequest())
        }
    }

    @Test func mapsOfflineError() async {
        URLProtocolStub.handler = { _ in throw URLError(.notConnectedToInternet) }

        await #expect(throws: FPLNetworkError.noInternet) {
            try await client.send(FPLBootstrapNetworkRequest())
        }
    }

    @Test func mapsTimeoutError() async {
        URLProtocolStub.handler = { _ in throw URLError(.timedOut) }

        await #expect(throws: FPLNetworkError.timeout) {
            try await client.send(FPLBootstrapNetworkRequest())
        }
    }

    @Test func errorsHaveUserFacingMessages() {
        #expect(FPLNetworkError.noInternet.message == FPLStringKey.errorNoInternet)
        #expect(FPLNetworkError.badStatus(500).message == FPLStringKey.errorServer)
        #expect(FPLNetworkError.decoding.message == FPLStringKey.errorDecoding)
        #expect(CocoaError(.fileNoSuchFile).fplMessage == FPLStringKey.errorGeneric)
    }
}
