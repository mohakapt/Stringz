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
  
  var appDelegate: AppDelegate {
    NSApplication.shared.delegate as! AppDelegate
  }
  
  @IBOutlet weak var automaticallyCheckForUpdatesButton: NSButton?
  @IBOutlet weak var automaticallyDownloadUpdatesButton: NSButton?
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear() {
    super.viewWillAppear()
    
    automaticallyCheckForUpdatesButton?.state = appDelegate.updaterController.automaticallyChecksForUpdates ? .on : .off
    
    automaticallyDownloadUpdatesButton?.state = appDelegate.updaterController.automaticallyDownloadsUpdates ? .on : .off
    
  }
  
  
  
  @IBAction func automaticallyCheckForUpdatesChanged(_ sender: NSButton) {
    appDelegate.updaterController.setAutomaticallyChecksForUpdates(sender.state == .on)
  }
  
  @IBAction func automaticallyDownloadUpdatesChanged(_ sender: NSButton) {
    appDelegate.updaterController.setAutomaticallyDownloadsUpdates(sender.state == .on)
  }
}
