//
//  FPLNetworkError.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import Foundation

// MARK: - FPLNetworkError

enum FPLNetworkError: Error, Equatable {
    case invalidURL
    case noInternet
    case timeout
    case invalidResponse
    case badStatus(Int)
    case decoding
    case unknown

    init(urlError: URLError) {
        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
            self = .noInternet
        case .timedOut:
            self = .timeout
        default:
            self = .unknown
        }
    }

    /// Short message that is safe to show to the user.
    var message: String {
        switch self {
        case .noInternet: FPLStringKey.errorNoInternet
        case .timeout: FPLStringKey.errorTimeout
        case .badStatus, .invalidResponse, .invalidURL: FPLStringKey.errorServer
        case .decoding: FPLStringKey.errorDecoding
        case .unknown: FPLStringKey.errorGeneric
        }
    }
}

extension Error {
    /// Maps any error to a user facing message.
    var fplMessage: String {
        (self as? FPLNetworkError)?.message ?? FPLStringKey.errorGeneric
    }
}
