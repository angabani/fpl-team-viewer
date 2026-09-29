//
//  FPLTestHelpers.swift
//  FPLTeamViewerTests
//
//  Created by AG on 29/09/26.
//

import Foundation
import Testing
@testable import FPLTeamViewer

// MARK: - Fixture

enum Fixture {
    private final class BundleToken {}

    static func bootstrapData() throws -> Data {
        let url = try #require(
            Bundle(for: BundleToken.self).url(forResource: "bootstrap_fixture", withExtension: "json")
        )
        return try Data(contentsOf: url)
    }

    static func bootstrapResponse() throws -> FPLBootstrapResponse {
        try FPLBootstrapResponse.decode(from: bootstrapData())
    }

    static func teams() throws -> [FPLTeam] {
        FPLBootstrapMapper.teams(from: try bootstrapResponse())
    }

    static func player(
        id: Int,
        webName: String,
        firstName: String = "First",
        secondName: String = "Second",
        position: FPLPosition = .midfielder,
        nowCost: Int = 50,
        totalPoints: Int = 0,
        status: FPLPlayerStatus = .available,
        news: String = ""
    ) -> FPLPlayer {
        FPLPlayer(
            id: id,
            firstName: firstName,
            secondName: secondName,
            webName: webName,
            teamID: 1,
            position: position,
            nowCost: nowCost,
            totalPoints: totalPoints,
            status: status,
            news: news,
            form: 0,
            selectedByPercent: 0
        )
    }

    static func snapshot(_ teams: [FPLTeam], at date: Date = Date(timeIntervalSince1970: 0)) -> FPLTeamsSnapshot {
        FPLTeamsSnapshot(teams: teams, updatedAt: date)
    }

    static func tempFileURL() -> URL {
        FileManager.default.temporaryDirectory
            .appending(path: UUID().uuidString, directoryHint: .isDirectory)
            .appending(path: "bootstrap.json")
    }
}

// MARK: - MockAPIClient

final class MockAPIClient: IFPLAPIClient, @unchecked Sendable {
    var result: Result<Data, Error>
    private(set) var callCount = 0

    init(result: Result<Data, Error>) {
        self.result = result
    }

    func send(_ request: IFPLNetworkRequest) async throws -> Data {
        callCount += 1
        return try result.get()
    }
}

// MARK: - InMemoryCacheStore

final class InMemoryCacheStore: IFPLCacheStore, @unchecked Sendable {
    var stored: FPLCachedData?
    var saveError: Error?

    init(stored: FPLCachedData? = nil) {
        self.stored = stored
    }

    func save(_ data: Data) throws {
        if let saveError { throw saveError }
        stored = FPLCachedData(data: data, savedAt: Date(timeIntervalSince1970: 100))
    }

    func load() throws -> FPLCachedData? {
        stored
    }

    func clear() throws {
        stored = nil
    }
}

// MARK: - MockFPLRepository

/// Returns queued results in order, one per `fetchTeams` call.
final class MockFPLRepository: IFPLRepository, @unchecked Sendable {
    var cached: FPLTeamsSnapshot?
    var fetchResults: [Result<FPLTeamsSnapshot, Error>]
    private(set) var fetchCount = 0

    init(cached: FPLTeamsSnapshot? = nil, fetchResults: [Result<FPLTeamsSnapshot, Error>] = []) {
        self.cached = cached
        self.fetchResults = fetchResults
    }

    func loadCachedTeams() async -> FPLTeamsSnapshot? {
        cached
    }

    func fetchTeams() async throws -> FPLTeamsSnapshot {
        fetchCount += 1
        guard !fetchResults.isEmpty else { throw FPLNetworkError.unknown }
        return try fetchResults.removeFirst().get()
    }
}

// MARK: - URLProtocolStub

/// Intercepts URLSession calls so API client tests never hit the network.
final class URLProtocolStub: URLProtocol {
    nonisolated(unsafe) static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        return URLSession(configuration: configuration)
    }

    static func response(status: Int, for request: URLRequest) throws -> HTTPURLResponse {
        guard let url = request.url,
              let response = HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil) else {
            throw URLError(.badURL)
        }
        return response
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
