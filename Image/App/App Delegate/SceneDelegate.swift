//
//  SceneDelegate.swift
//  Image
//
//  Created by 서상의 on 2021/11/14.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    private let imageProvider = KakaoImageProvider()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let useCaseImageSearch = UseCaseImageSearch(provider: self.imageProvider)
        
        self.window = .init(windowScene: windowScene)
        self.window?.rootViewController = SearchViewController(viewModel: .init(imageSearchUseCase: useCaseImageSearch))
        self.window?.makeKeyAndVisible()
    }
}

