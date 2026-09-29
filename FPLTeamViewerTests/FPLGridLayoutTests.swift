//
//  FPLGridLayoutTests.swift
//  FPLTeamViewerTests
//
//  Created by AG on 29/09/26.
//

import Foundation
import Testing
@testable import FPLTeamViewer

struct FPLGridLayoutTests {
    private let cardWidth: CGFloat = 320
    private let spacing: CGFloat = 16

    @Test func narrowWidthGivesOneColumn() {
        #expect(FPLGridLayout.columnCount(for: 402, minimumCardWidth: cardWidth, spacing: spacing) == 1)
    }

    @Test func neverLessThanOneColumn() {
        #expect(FPLGridLayout.columnCount(for: 100, minimumCardWidth: cardWidth, spacing: spacing) == 1)
        #expect(FPLGridLayout.columnCount(for: 0, minimumCardWidth: cardWidth, spacing: spacing) == 1)
    }

    @Test func columnsGrowWithWidth() {
        // Exactly two cards and one gap.
        #expect(FPLGridLayout.columnCount(for: 656, minimumCardWidth: cardWidth, spacing: spacing) == 2)
        // One point short of that.
        #expect(FPLGridLayout.columnCount(for: 655, minimumCardWidth: cardWidth, spacing: spacing) == 1)
        #expect(FPLGridLayout.columnCount(for: 1_180, minimumCardWidth: cardWidth, spacing: spacing) == 3)
    }

    @Test func largerTextMeansFewerColumns() {
        let width: CGFloat = 1_000
        let normal = FPLGridLayout.columnCount(for: width, minimumCardWidth: cardWidth, spacing: spacing)
        let large = FPLGridLayout.columnCount(for: width, minimumCardWidth: cardWidth * 1.5, spacing: spacing)
        #expect(large < normal)
    }
}
