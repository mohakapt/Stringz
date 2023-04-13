//
//  ExportingPreferenceViewController.swift
//  Stringz
//
//  Created by Heysem Katibi on 22.12.2020.
//

import Cocoa
import Preferences

final class ExportingPreferenceViewController: PreferenceViewController, PreferencePane {
  let preferencePaneIdentifier = Preferences.PaneIdentifier.exporting
  let preferencePaneTitle = "Exporting"
  lazy var toolbarItemIcon = NSImage(systemSymbolName: "arrow.up.doc", accessibilityDescription: preferencePaneTitle)!

  override var nibName: NSNib.Name? { "ExportingPreference" }

  override func viewDidLoad() {
    super.viewDidLoad()
  }
}
