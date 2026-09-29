//
//  Date+Formatting.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import Foundation

extension Date {
    /// e.g. "29 Sep, 11:40".
    var fplShortText: String {
        formatted(.dateTime.day().month(.abbreviated).hour().minute())
    }
}
