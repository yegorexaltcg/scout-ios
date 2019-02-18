//
//  AppDelegate.swift
//  Scout
//
//

import AVFoundation
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let applicationRouter: ApplicationRouterProtocol
    let applicationAssembly: ApplicationAssemblyProtocol
    let keychainService: KeychainService

    override init() {
        let configuration = AppConfiguration()

        // Set up audio session here, since it's used by both the player and the speech service.
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: .defaultToSpeaker)
            try audioSession.setActive(true, options: [.notifyOthersOnDeactivation])
        } catch {}

        self.applicationAssembly = ApplicationAssembly(with: configuration)
        self.applicationRouter = ApplicationRouter(with: self.applicationAssembly)
        // swiftlint:disable:next force_cast
        self.keychainService = self.applicationAssembly.assemblyKeychainService() as! KeychainService

        super.init()
        self.setDefaultPreferences()
    }

    private func setDefaultPreferences() {
        UserDefaults().register(defaults: [
            "articlePlaybackSpeed": 1.0,
            "podcastPlaybackSpeed": 1.0,
            "showRecommendedArticles": true,
            "sendUsageData": true,
            "listenForWakeWord": true
        ])
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let result = self.applicationRouter.application!(application, didFinishLaunchingWithOptions: launchOptions)
        if keychainService.value(for: "userID") != nil {
            self.setupMainScreen()
        } else {
            self.setupWindow()
        }

        return result
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        var mainRouter = self.applicationAssembly.assemblyMainRouter()
        mainRouter.userID = url.lastPathComponent

        self.setupMainScreen()
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        self.applicationRouter.applicationDidBecomeActive()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        self.applicationRouter.applicationWillResignActive()
    }
}

// MARK: -
// MARK: Private
fileprivate extension AppDelegate {
    func setupWindow() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = UIColor.white
        self.window = window

        self.applicationRouter.show(from: window)
    }

    func setupMainScreen() {
        if keychainService.value(for: "userID") != nil {
            var mainRouter = self.applicationAssembly.assemblyMainRouter()
            mainRouter.userID = keychainService.value(for: "userID")!
        }

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = UIColor.white
        self.window = window

        self.applicationRouter.showMain(from: window)
    }
}