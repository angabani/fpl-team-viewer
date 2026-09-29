//
//  FPLAPIClient.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import Foundation

private enum Constants {
    static let successStatusCodes = 200...299
}

// MARK: - IFPLAPIClient

protocol IFPLAPIClient: Sendable {
    /// Returns the raw body. Raw data is kept so the repository can cache it as is.
    func send(_ request: IFPLNetworkRequest) async throws -> Data
}

// MARK: - FPLAPIClient

/// Thin wrapper on URLSession. Checks the status code and maps errors.
struct FPLAPIClient: IFPLAPIClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func send(_ request: IFPLNetworkRequest) async throws -> Data {
        let urlRequest = try request.makeURLRequest()

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()
        } catch let error as URLError {
            throw FPLNetworkError(urlError: error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw FPLNetworkError.invalidResponse
        }
        guard Constants.successStatusCodes.contains(httpResponse.statusCode) else {
            throw FPLNetworkError.badStatus(httpResponse.statusCode)
        }
        return data
    }
}
