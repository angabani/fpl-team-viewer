//
//  FPLViewState.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import Foundation

// MARK: - FPLViewState

/// What a screen shows. Refresh is not a state here on purpose:
/// during a refresh the screen stays `.loaded` so data never disappears.
enum FPLViewState<Content> {
    case loading
    case loaded(Content)
    case empty(title: String, message: String)
    case failed(message: String)
}

extension FPLViewState: Equatable where Content: Equatable {}

extension FPLViewState {
    var content: Content? {
        if case .loaded(let content) = self { return content }
        return nil
    }
}
