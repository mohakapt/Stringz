//
//  GeneralPreferenceViewController.swift
//  Stringz
//
//  Created by Heysem Katibi on 9.12.2020.
//

import Cocoa
import Preferences
import Sparkle

final class GeneralPreferenceViewController: PreferenceViewController, PreferencePane {
  let preferencePaneIdentifier = Preferences.PaneIdentifier.general
  let preferencePaneTitle = "General"
  let toolbarItemIcon = NSImage(named: "preferences.general")!
  override var nibName: NSNib.Name? { "GeneralPreference" }

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  var appDelegate: AppDelegate {
    NSApplication.shared.delegate as! AppDelegate
  }

  @IBAction func automaticallyCheckForUpdatesChanged(_ sender: NSButton) {
    appDelegate.updaterController.updater.automaticallyChecksForUpdates = sender.state == .on
  }

  @IBAction func automaticallyDownloadUpdatesChanged(_ sender: NSButton) {
    appDelegate.updaterController.updater.automaticallyDownloadsUpdates = sender.state == .on
  }
}
