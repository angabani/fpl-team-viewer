//
//  Array+Safe.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
