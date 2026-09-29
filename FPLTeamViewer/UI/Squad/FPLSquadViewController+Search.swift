//
//  FPLSquadViewController+Search.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import UIKit

// MARK: - Search

extension FPLSquadViewController: UISearchResultsUpdating {
    func setupSearch() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = FPLStringKey.searchPlayersPlaceholder
        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.autocapitalizationType = .none

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    /// Called on every keystroke.
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.search(searchController.searchBar.text ?? "")
    }
}
