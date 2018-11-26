//
//  ApplicationRouter.swift
//  Scout
//
//

import UIKit

class ApplicationRouter: NSObject {
    let applicationAssembly: ApplicationAssemblyProtocol

    fileprivate var navigationController: UINavigationController!
    fileprivate var mainRouter: MainRoutingProtocol
    fileprivate var podcastsRouter: PodcastsRoutingProtocol
    fileprivate var myListRouter: MyListRoutingProtocol
    fileprivate var authRouter: AuthRoutingProtocol
    fileprivate var voiceInputRouter: VoiceInputRoutingProtocol
    fileprivate var playerRouter: PlayerRoutingProtocol

    required init(with applicationAssembly: ApplicationAssemblyProtocol) {
        self.applicationAssembly = applicationAssembly

        // Routers
        self.mainRouter = applicationAssembly.assemblyMainRouter()
        self.myListRouter = applicationAssembly.assemblyMyListRouter()
        self.authRouter = applicationAssembly.assemblyAuthRouter()
        self.voiceInputRouter = applicationAssembly.assemblyVoiceInputRouter()
        self.playerRouter = applicationAssembly.assemblyPlayerRouter()
        self.podcastsRouter = applicationAssembly.assemblyPodcastsRouter()
        super.init()
    }
}

// MARK: -
// MARK: ApplicationRouter
extension ApplicationRouter: ApplicationRouterProtocol {
    func show(from window: UIWindow) {
        self.showLogin(from: window)
    }

    func showMain(from window: UIWindow) {
        self.showMainScreen(from: window)
    }
}

// MARK: -
// MARK: UIApplicationDelegate
extension ApplicationRouter {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}

// MARK: -
// MARK: Private
private extension ApplicationRouter {
    func showLogin(from window: UIWindow) {
        let navVC = UINavigationController()
        navVC.isNavigationBarHidden = true
        window.rootViewController = navVC
        self.navigationController = navVC
        window.makeKeyAndVisible()

        self.showAuthStory(animated: true)
    }

    func showMainScreen(from window: UIWindow) {
        let navVC = UINavigationController()
        navVC.isNavigationBarHidden = true
        window.rootViewController = navVC
        self.navigationController = navVC
        window.makeKeyAndVisible()

        self.showMainStory(viewController: self.navigationController, animated: true)
    }

    func showMainStory(viewController: UINavigationController, animated: Bool, completion: VoidBlock? = nil) {
        self.mainRouter.showMainUIInterface(fromViewController: viewController, animated: false)
        self.mainRouter.showMainUITab(tab: .articles, animated: false)
        self.myListRouter.linkIsFound = { [] scoutArticle, isFullArticle in
            self.playerRouter.show(from: self.navigationController,
                                   animated: true,
                                   model: scoutArticle,
                                   fullArticle: isFullArticle)
            self.playerRouter.onBackButtonTap = { [] in
                self.removePlayerViewController()
            }
        }
        self.myListRouter.openVoiceInput = { () in
            self.voiceInputRouter.show(from: self.navigationController, animated: true)
            self.voiceInputRouter.onCloseButtonTap = { [] in
                self.removeVoiceInputViewController()
            }
        }
        self.myListRouter.hideVoiceInput = { () in
            self.removeVoiceInputViewController()
        }
        self.myListRouter.addVoiceInputText = { (text, fromUser) in
            self.voiceInputRouter.addText(text, fromUser: fromUser)
        }
        self.myListRouter.setVoiceInputImage = { (image) in
            self.voiceInputRouter.setImage(image)
        }
        self.myListRouter.pausePlayer = {
            self.playerRouter.pause()
        }
        self.myListRouter.stopPlayer = {
            self.playerRouter.stop()
        }
        self.myListRouter.resumePlayer = {
            self.playerRouter.resume()
        }
        self.myListRouter.isPlaying = {
            return self.playerRouter.playing()
        }
        self.myListRouter.isPlayerVisible = {
            return self.playerRouter.playerVisible()
        }
        self.myListRouter.increasePlayerVolume = {
            self.playerRouter.increaseVolume()
        }
        self.myListRouter.decreasePlayerVolume = {
            self.playerRouter.decreaseVolume()
        }
        self.myListRouter.setPlayerVolume = { (volume) in
            return self.playerRouter.setVolume(volume)
        }
        self.myListRouter.increasePlayerSpeed = {
            self.playerRouter.increaseSpeed()
        }
        self.myListRouter.decreasePlayerSpeed = {
            self.playerRouter.decreaseSpeed()
        }
        self.myListRouter.skipPlayerTime = { (seconds) in
            self.playerRouter.skip(seconds)
        }
        self.podcastsRouter.linkIsFound = { [] in
            self.podcastsRouter.showPodcastDetails(from: self.navigationController,
                                                   animated: true,
                                                   withUserID: self.mainRouter.userID)
        }
        self.podcastsRouter.addPodcasts = { [] in
            self.podcastsRouter.showAddPodcasts(from: self.navigationController,
                                                animated: true,
                                                withUserID: self.mainRouter.userID)
        }
        self.podcastsRouter.openVoiceInput = { () in
            self.voiceInputRouter.show(from: self.navigationController, animated: true)
            self.voiceInputRouter.onCloseButtonTap = { [] in
                self.removeVoiceInputViewController()
            }
        }
        self.podcastsRouter.hideVoiceInput = { () in
            self.removeVoiceInputViewController()
        }
        self.podcastsRouter.addVoiceInputText = { (text, fromUser) in
            self.voiceInputRouter.addText(text, fromUser: fromUser)
        }
        self.podcastsRouter.setVoiceInputImage = { (image) in
            self.voiceInputRouter.setImage(image)
        }
    }

    func showAuthStory(animated: Bool, completion: VoidBlock? = nil) {
        self.authRouter.show(from: self.navigationController, animated: true)
        if let requiredCompletion = completion { requiredCompletion() }
    }

    private func removeVoiceInputViewController() {
        var viewControllers = self.navigationController.viewControllers
        for (index, element) in viewControllers.enumerated() where element as? VoiceInputViewController != nil {
            viewControllers.remove(at: index)
            self.navigationController.setViewControllers(viewControllers, animated: true)
            break
        }
    }

    private func removePlayerViewController() {
        var viewControllers = self.navigationController.viewControllers
        for (index, element) in viewControllers.enumerated() where element as? PlayerViewController != nil {
            viewControllers.remove(at: index)
            self.navigationController.setViewControllers(viewControllers, animated: true)
            break
        }
    }
}
