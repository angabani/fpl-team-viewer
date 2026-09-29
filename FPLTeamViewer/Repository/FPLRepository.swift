//
//  FPLRepository.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import Foundation

// MARK: - IFPLRepository

protocol IFPLRepository: Sendable {
    /// Last saved data, or nil if there is no usable cache.
    func loadCachedTeams() async -> FPLTeamsSnapshot?
    /// Fresh data from the API. Saves it to cache on success.
    func fetchTeams() async throws -> FPLTeamsSnapshot
}

// MARK: - FPLRepository

/// Single source of data for the screens.
/// View models do not know if data came from network or disk.
struct FPLRepository: IFPLRepository {
    private let apiClient: IFPLAPIClient
    private let cacheStore: IFPLCacheStore
    private let now: @Sendable () -> Date

    init(
        apiClient: IFPLAPIClient,
        cacheStore: IFPLCacheStore,
        now: @escaping @Sendable () -> Date = { .now }
    ) {
        self.apiClient = apiClient
        self.cacheStore = cacheStore
        self.now = now
    }

    func loadCachedTeams() async -> FPLTeamsSnapshot? {
        // A broken cache file is treated as no cache.
        guard let cached = try? cacheStore.load(),
              let response = try? FPLBootstrapResponse.decode(from: cached.data) else {
            return nil
        }
        return FPLTeamsSnapshot(teams: FPLBootstrapMapper.teams(from: response), updatedAt: cached.savedAt)
    }

    func fetchTeams() async throws -> FPLTeamsSnapshot {
        let data = try await apiClient.send(FPLBootstrapNetworkRequest())

        let response: FPLBootstrapResponse
        do {
            response = try FPLBootstrapResponse.decode(from: data)
        } catch {
            throw FPLNetworkError.decoding
        }

        // Save only after decode works, so a bad response never replaces good cache.
        // A failed save should not fail the screen, the user still gets fresh data.
        try? cacheStore.save(data)

        return FPLTeamsSnapshot(teams: FPLBootstrapMapper.teams(from: response), updatedAt: now())
    }
}
