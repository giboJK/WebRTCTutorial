//
//  SceneDelegate.swift
//  WebRTCTutorial
//
//  Created by 정김기보 on 2021/02/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let config = Config.default


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = ExampleListViewController()
        window?.makeKeyAndVisible()
    }
    
}

