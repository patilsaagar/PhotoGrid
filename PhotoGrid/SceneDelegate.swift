//
//  SceneDelegate.swift
//  PhotoGrid
//
//  Created by Saggy on 09/01/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let networkManager = NetworkManager(urlSession: URLSession.shared)
        let photoViewModel = PhotoGridViewModel(networkFetcher: networkManager)
        let imageCache = ImageCache()
        let photoGridViewController = PhotoGridViewController(photoViewModel: photoViewModel, imageCache: imageCache)
        
        let navigationController = UINavigationController(rootViewController: photoGridViewController)
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
    }
}

