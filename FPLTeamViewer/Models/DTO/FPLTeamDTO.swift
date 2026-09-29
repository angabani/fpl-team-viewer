//
//  FPLTeamDTO.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import Foundation

// MARK: - FPLTeamDTO

/// A team as it comes from the API (`teams` array).
struct FPLTeamDTO: Decodable, Sendable {
    let id: Int
    let name: String
    let shortName: String
}
