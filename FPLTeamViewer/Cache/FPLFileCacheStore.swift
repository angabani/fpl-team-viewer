//
//  FPLFileCacheStore.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import Foundation

private enum Constants {
    static let folderName = "FPLCache"
    static let fileName = "bootstrap.json"
}

// MARK: - FPLCachedData

struct FPLCachedData: Sendable, Equatable {
    let data: Data
    let savedAt: Date
}

// MARK: - IFPLCacheStore

protocol IFPLCacheStore: Sendable {
    func save(_ data: Data) throws
    /// Returns nil when nothing is cached yet.
    func load() throws -> FPLCachedData?
    func clear() throws
}

// MARK: - FPLFileCacheStore

/// Keeps the last good API response as a JSON file.
/// Application Support is used, not Caches, so the OS does not purge it.
struct FPLFileCacheStore: IFPLCacheStore {
    private let fileURL: URL

    init(fileURL: URL = FPLFileCacheStore.defaultFileURL) {
        self.fileURL = fileURL
    }

    static var defaultFileURL: URL {
        URL.applicationSupportDirectory
            .appending(path: Constants.folderName, directoryHint: .isDirectory)
            .appending(path: Constants.fileName)
    }

    func save(_ data: Data) throws {
        let folder = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        // Atomic write, so a crash mid write never leaves a half file.
        try data.write(to: fileURL, options: .atomic)
    }

    func load() throws -> FPLCachedData? {
        guard FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) else { return nil }
        let data = try Data(contentsOf: fileURL)
        let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path(percentEncoded: false))
        let savedAt = attributes[.modificationDate] as? Date ?? .now
        return FPLCachedData(data: data, savedAt: savedAt)
    }

    func clear() throws {
        guard FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) else { return }
        try FileManager.default.removeItem(at: fileURL)
    }
}
