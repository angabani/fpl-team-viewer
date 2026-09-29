//
//  FPLCacheTests.swift
//  FPLTeamViewerTests
//
//  Created by AG on 29/09/26.
//

import Foundation
import Testing
@testable import FPLTeamViewer

// MARK: - File cache

struct FPLFileCacheStoreTests {
    private let store = FPLFileCacheStore(fileURL: Fixture.tempFileURL())

    @Test func loadReturnsNilWhenNothingSaved() throws {
        #expect(try store.load() == nil)
    }

    @Test func saveThenLoadReturnsSameData() throws {
        let data = Data("cached".utf8)
        try store.save(data)

        let cached = try #require(try store.load())
        #expect(cached.data == data)
        #expect(abs(cached.savedAt.timeIntervalSinceNow) < 60)
    }

    /// The real folder is "Application Support", so the path has a space.
    @Test func worksWhenPathHasSpaces() throws {
        let url = FileManager.default.temporaryDirectory
            .appending(path: "Folder With Space \(UUID().uuidString)", directoryHint: .isDirectory)
            .appending(path: "bootstrap.json")
        let store = FPLFileCacheStore(fileURL: url)

        try store.save(Data("cached".utf8))
        #expect(try store.load()?.data == Data("cached".utf8))
    }

    @Test func saveOverwritesOldData() throws {
        try store.save(Data("old".utf8))
        try store.save(Data("new".utf8))
        #expect(try store.load()?.data == Data("new".utf8))
    }

    @Test func clearWithNothingSavedDoesNotThrow() throws {
        try store.clear()
        #expect(try store.load() == nil)
    }

    @Test func defaultLocationIsApplicationSupport() {
        let url = FPLFileCacheStore.defaultFileURL
        #expect(url.path(percentEncoded: false).contains("Application Support"))
        #expect(url.lastPathComponent == "bootstrap.json")
    }

    @Test func clearRemovesData() throws {
        try store.save(Data("cached".utf8))
        try store.clear()
        #expect(try store.load() == nil)
    }
}

// MARK: - Repository cache behaviour

struct FPLRepositoryTests {
    @Test func successfulFetchReturnsTeamsAndSavesCache() async throws {
        let data = try Fixture.bootstrapData()
        let cache = InMemoryCacheStore()
        let fetchedAt = Date(timeIntervalSince1970: 500)
        let repository = FPLRepository(apiClient: MockAPIClient(result: .success(data)), cacheStore: cache, now: { fetchedAt })

        let snapshot = try await repository.fetchTeams()

        #expect(snapshot.teams.count == 3)
        #expect(snapshot.updatedAt == fetchedAt)
        #expect(cache.stored?.data == data)
    }

    @Test func failedFetchKeepsOldCache() async throws {
        let oldData = try Fixture.bootstrapData()
        let cache = InMemoryCacheStore(stored: FPLCachedData(data: oldData, savedAt: .now))
        let repository = FPLRepository(apiClient: MockAPIClient(result: .failure(FPLNetworkError.noInternet)), cacheStore: cache)

        await #expect(throws: FPLNetworkError.noInternet) {
            try await repository.fetchTeams()
        }
        #expect(cache.stored?.data == oldData)
    }

    @Test func badResponseThrowsDecodingAndDoesNotReplaceCache() async throws {
        let oldData = try Fixture.bootstrapData()
        let cache = InMemoryCacheStore(stored: FPLCachedData(data: oldData, savedAt: .now))
        let repository = FPLRepository(apiClient: MockAPIClient(result: .success(Data("{}".utf8))), cacheStore: cache)

        await #expect(throws: FPLNetworkError.decoding) {
            try await repository.fetchTeams()
        }
        #expect(cache.stored?.data == oldData)
    }

    @Test func cacheSaveFailureStillReturnsFreshData() async throws {
        let cache = InMemoryCacheStore()
        cache.saveError = CocoaError(.fileWriteNoPermission)
        let repository = FPLRepository(apiClient: MockAPIClient(result: .success(try Fixture.bootstrapData())), cacheStore: cache)

        let snapshot = try await repository.fetchTeams()
        #expect(snapshot.teams.count == 3)
    }

    @Test func loadCachedTeamsDecodesSavedData() async throws {
        let savedAt = Date(timeIntervalSince1970: 1_000)
        let cache = InMemoryCacheStore(stored: FPLCachedData(data: try Fixture.bootstrapData(), savedAt: savedAt))
        let repository = FPLRepository(apiClient: MockAPIClient(result: .failure(FPLNetworkError.noInternet)), cacheStore: cache)

        let snapshot = try #require(await repository.loadCachedTeams())
        #expect(snapshot.teams.map(\.shortName) == ["ARS", "AVL", "CHE"])
        #expect(snapshot.updatedAt == savedAt)
    }

    @Test func loadCachedTeamsReturnsNilForCorruptFile() async throws {
        let store = FPLFileCacheStore(fileURL: Fixture.tempFileURL())
        try store.save(Data("corrupt".utf8))
        let repository = FPLRepository(apiClient: MockAPIClient(result: .failure(FPLNetworkError.noInternet)), cacheStore: store)

        #expect(await repository.loadCachedTeams() == nil)
    }

    @Test func loadCachedTeamsReturnsNilWhenEmpty() async {
        let repository = FPLRepository(apiClient: MockAPIClient(result: .failure(FPLNetworkError.noInternet)), cacheStore: InMemoryCacheStore())
        #expect(await repository.loadCachedTeams() == nil)
    }
}
