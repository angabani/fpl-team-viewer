//
//  SceneDelegate.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var coordinator: FPLAppCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)

        if FPLAppDependencies.isRunningUnitTests {
            // Unit tests use the app as host. Skip the real UI so no network call is made.
            window.rootViewController = UIViewController()
        } else {
            let coordinator = FPLAppCoordinator(dependencies: .live())
            window.rootViewController = coordinator.start()
            self.coordinator = coordinator
        }

        window.makeKeyAndVisible()
        self.window = window
    }
}
