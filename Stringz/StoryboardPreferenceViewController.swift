//
//  StoryboardPreferenceViewController.swift
//  Stringz
//
//  Created by Heysem Katibi on 22.12.2020.
//

import Cocoa
import Preferences
import PathKit

final class StoryboardPreferenceViewController: PreferenceViewController, PreferencePane {
  let preferencePaneIdentifier = Preferences.PaneIdentifier.xib
  let preferencePaneTitle = "Storyboard"
  lazy var toolbarItemIcon = NSImage(systemSymbolName: "paintbrush.pointed", accessibilityDescription: preferencePaneTitle)!

  override var nibName: NSNib.Name? { "StoryboardPreference" }

  @IBOutlet weak var pathControl: NSPathControl!
  @IBOutlet weak var changeLocationButton: NSButton!

  override func viewDidLoad() {
    super.viewDidLoad()

    if let path = UserDefaults.storyboardXcodePath, let url = URL(string: "file://\(path)") {
      pathControl.url = url
    }
  }

  @IBAction func changeLocationClicked(_ sender: Any) {
  }
}
