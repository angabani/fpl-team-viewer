//
//  AppDelegate.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import UIKit

private enum Constants {
    static let sceneConfigurationName = "Default Configuration"
}

/// App entry point. All UI setup lives in `SceneDelegate`.
@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: Constants.sceneConfigurationName, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}
