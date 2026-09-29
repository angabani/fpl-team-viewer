//
//  FPLBootstrapNetworkRequest.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import Foundation

private enum Constants {
    static let timeout: TimeInterval = 20
    static let method = "GET"
    static let acceptHeader = "Accept"
    static let jsonContentType = "application/json"
}

// MARK: - IFPLNetworkRequest

protocol IFPLNetworkRequest: Sendable {
    func makeURLRequest() throws -> URLRequest
}

// MARK: - FPLBootstrapNetworkRequest

/// GET bootstrap-static. One call gives teams, players and positions.
struct FPLBootstrapNetworkRequest: IFPLNetworkRequest {
    var timeout: TimeInterval = Constants.timeout

    func makeURLRequest() throws -> URLRequest {
        guard let url = URL(string: URLConstants.bootstrapStatic) else {
            throw FPLNetworkError.invalidURL
        }
        // Cache is handled by the app, so always ask the server for fresh data.
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: timeout)
        request.httpMethod = Constants.method
        request.setValue(Constants.jsonContentType, forHTTPHeaderField: Constants.acceptHeader)
        return request
    }
}
