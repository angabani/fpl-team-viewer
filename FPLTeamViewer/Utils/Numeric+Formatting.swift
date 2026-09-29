//
//  Numeric+Formatting.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import Foundation

private enum Constants {
    /// API sends price in tenths of a million.
    static let costUnitsPerMillion = 10.0
    static let oneFractionDigit = 1
    /// Fixed so numbers always read like FPL, e.g. "6.1" not "6,1".
    static let numberLocale = Locale(identifier: "en_GB")
}

extension Int {
    /// FPL price text. 61 -> "£6.1m".
    var fplPriceText: String {
        let millions = Double(self) / Constants.costUnitsPerMillion
        return FPLStringKey.price(millions.fplOneDecimalText)
    }
}

extension Double {
    /// One decimal place, e.g. 6 -> "6.0". Used for price, form and ownership.
    var fplOneDecimalText: String {
        formatted(
            .number
                .precision(.fractionLength(Constants.oneFractionDigit))
                .locale(Constants.numberLocale)
        )
    }
}
