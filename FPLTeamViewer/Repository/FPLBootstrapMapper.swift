//
//  FPLBootstrapMapper.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import Foundation

// MARK: - FPLBootstrapMapper

/// Turns API DTOs into app models. Pure functions, easy to test.
enum FPLBootstrapMapper {
    /// Teams sorted by name, each with its players.
    /// Players with an unknown position are skipped.
    static func teams(from response: FPLBootstrapResponse) -> [FPLTeam] {
        let playersByTeam = Dictionary(grouping: response.elements.compactMap(player(from:)), by: \.teamID)

        return response.teams
            .map { dto in
                FPLTeam(
                    id: dto.id,
                    name: dto.name,
                    shortName: dto.shortName,
                    players: playersByTeam[dto.id] ?? []
                )
            }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    static func player(from dto: FPLPlayerDTO) -> FPLPlayer? {
        guard let position = FPLPosition(rawValue: dto.elementType) else { return nil }
        return FPLPlayer(
            id: dto.id,
            firstName: dto.firstName,
            secondName: dto.secondName,
            webName: dto.webName,
            teamID: dto.team,
            position: position,
            nowCost: dto.nowCost,
            totalPoints: dto.totalPoints,
            status: FPLPlayerStatus(code: dto.status),
            news: dto.news?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            form: Double(dto.form ?? "") ?? 0,
            selectedByPercent: Double(dto.selectedByPercent ?? "") ?? 0
        )
    }

    /// Groups players by position (GKP, DEF, MID, FWD).
    /// Inside a group: most points first, then name. Empty groups are dropped.
    static func squadSections(from players: [FPLPlayer]) -> [FPLSquadSection] {
        let grouped = Dictionary(grouping: players, by: \.position)

        return FPLPosition.allCases.compactMap { position in
            guard let players = grouped[position], !players.isEmpty else { return nil }
            let sorted = players.sorted { lhs, rhs in
                if lhs.totalPoints != rhs.totalPoints {
                    return lhs.totalPoints > rhs.totalPoints
                }
                return lhs.webName.localizedStandardCompare(rhs.webName) == .orderedAscending
            }
            return FPLSquadSection(position: position, players: sorted)
        }
    }
}
