//
//  FPLBootstrapResponse.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import Foundation

// MARK: - FPLBootstrapResponse

/// Raw response of `bootstrap-static`. I only decode what the app needs.
/// Keys are snake_case in the API, the decoder converts them.
struct FPLBootstrapResponse: Decodable, Sendable {
    let teams: [FPLTeamDTO]
    let elements: [FPLPlayerDTO]
}

extension FPLBootstrapResponse {
    static func decode(from data: Data) throws -> FPLBootstrapResponse {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(FPLBootstrapResponse.self, from: data)
    }
}
