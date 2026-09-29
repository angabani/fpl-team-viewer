//
//  FPLAppDependencies.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import Foundation

private enum Constants {
    static let testCaseClassName = "XCTestCase"
}

// MARK: - FPLAppDependencies

/// Everything the screens need, built once at launch and passed down.
/// Tests build their own with mocks.
struct FPLAppDependencies {
    let repository: IFPLRepository

    static func live() -> FPLAppDependencies {
        let repository = FPLRepository(
            apiClient: FPLAPIClient(),
            cacheStore: FPLFileCacheStore()
        )
        return FPLAppDependencies(repository: repository)
    }

    static var isRunningUnitTests: Bool {
        NSClassFromString(Constants.testCaseClassName) != nil
    }
}
