//
//  GeneralPreferenceViewController.swift
//  Stringz
//
//  Created by Heysem Katibi on 9.12.2020.
//

import Cocoa
import Preferences

final class GeneralPreferenceViewController: PreferenceViewController, PreferencePane {
  let preferencePaneIdentifier = Preferences.PaneIdentifier.general
  let preferencePaneTitle = "General"
  let toolbarItemIcon = NSImage(named: "preferences.general")!
  override var nibName: NSNib.Name? { "GeneralPreference" }

  override func viewDidLoad() {
    super.viewDidLoad()
  }
}
