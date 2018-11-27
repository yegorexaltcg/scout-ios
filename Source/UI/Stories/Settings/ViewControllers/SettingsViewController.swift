//
//  SettingsViewController.swift
//  Scout
//
//  Created by Victor Liubchenko on 5/9/18.
//

import Foundation
import SafariServices
import UIKit

class SettingsViewController: UIViewController, SFSafariViewControllerDelegate {
    @IBOutlet fileprivate weak var mainTitleLabel: UILabel!
    @IBOutlet fileprivate var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate var gradientButton: GradientButton!

    private var safariVC: SFSafariViewController?
    private var userDefaults: UserDefaults = UserDefaults()

    var keychainService: KeychainService!

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var articleAudioRateButton: UIButton!
    @IBOutlet weak var podcastAudioRateButton: UIButton!
    @IBOutlet weak var showRecommendedArticlesSwitch: UISwitch!
    @IBOutlet weak var sendUsageDataSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureUI()
    }

    // MARK: Private
    fileprivate func configureUI() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.tapFunction))
        infoLabel.isUserInteractionEnabled = true
        infoLabel.addGestureRecognizer(tap)

        gradientButton.direction = .horizontally(centered: 0.1)

        let rawCenterString: NSString = """
        Mozilla strives to only collect what we need to provide and improve Firefox Listen for everyone. Learn More.
        """
        let centerText = NSMutableAttributedString(string: rawCenterString as String,
                                                   attributes: [
                                                       NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)
                                                   ])

        let policyText = "Learn More."
        let policyRange = rawCenterString.range(of: policyText)
        rawCenterString.enumerateSubstrings(in: policyRange, options: .byWords, using: { (_, substringRange, _, _) in
            centerText.addAttribute(NSAttributedString.Key.foregroundColor,
                                    value: UIColor(rgb: 0x0060DF),
                                    range: substringRange)
            })

        infoLabel.attributedText = centerText

        if let userID = keychainService.value(for: "userID") {
            accountLabel.text = "Account (\(userID))"
        }

        showRecommendedArticlesSwitch.isOn = userDefaults.bool(forKey: "showRecommendedArticles")
        sendUsageDataSwitch.isOn = userDefaults.bool(forKey: "sendUsageData")
        self.articleAudioRateButton.setTitle(
            String(format: "%.2fx", userDefaults.float(forKey: "articlePlaybackSpeed")), for: .normal)
        self.podcastAudioRateButton.setTitle(
            String(format: "%.2fx", userDefaults.float(forKey: "podcastPlaybackSpeed")), for: .normal)
    }

    @objc func tapFunction(sender: UITapGestureRecognizer) {
        guard let privacyURL = URL(string: "https://www.mozilla.org/en-US/privacy/") else {
            return //be safe
        }

        safariVC = SFSafariViewController(url: privacyURL)
        safariVC!.delegate = self
        self.present(safariVC!, animated: true, completion: nil)
    }

    @IBAction func articleAudioRateButtonTapped(_ sender: Any) {
        var current = self.userDefaults.float(forKey: "articlePlaybackSpeed")
        current += 0.25
        if current > 3.0 {
            current = 0.5
        }

        self.userDefaults.set(current, forKey: "articlePlaybackSpeed")

        DispatchQueue.main.async {
            self.articleAudioRateButton.setTitle(String(format: "%.2fx", current), for: .normal)
        }
    }

    @IBAction func podcastAudioRateButtonTapped(_ sender: Any) {
        var current = self.userDefaults.float(forKey: "podcastPlaybackSpeed")
        current += 0.25
        if current > 3.0 {
            current = 0.5
        }

        self.userDefaults.set(current, forKey: "podcastPlaybackSpeed")

        DispatchQueue.main.async {
            self.podcastAudioRateButton.setTitle(String(format: "%.2fx", current), for: .normal)
        }
    }

    @IBAction func showRecommendedArticlesValueChanged(_ sender: Any) {
        self.userDefaults.set(self.showRecommendedArticlesSwitch.isOn, forKey: "showRecommendedArticles")
    }

    @IBAction func enableSharingButtonTapped(_ sender: Any) {
    }

    @IBAction func sendUsageDataValueChanged(_ sender: Any) {
        self.userDefaults.set(self.sendUsageDataSwitch.isOn, forKey: "sendUsageData")
    }

    @IBAction func signOutButtonTapped(_ sender: Any) {
    }

    @IBAction func feedbackButtonTapped(_ sender: Any) {
    }

    @IBAction func privacyNoticeButtonTapped(_ sender: Any) {
    }
}