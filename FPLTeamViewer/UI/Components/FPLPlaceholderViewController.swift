//
//  FPLPlaceholderViewController.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import UIKit

/// Right column on wide screens before a team is picked.
final class FPLPlaceholderViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground

        var configuration = UIContentUnavailableConfiguration.empty()
        configuration.image = UIImage(systemName: FPLImageName.placeholder)
        configuration.text = FPLStringKey.selectTeamTitle
        configuration.secondaryText = FPLStringKey.selectTeamMessage
        contentUnavailableConfiguration = configuration
    }
}
