//
//  AppScenes.swift
//  Stringz
//
//  Created by Heysem Katibi on 2.01.2021.
//

import Cocoa

extension NSStoryboard.Name {
  static let main = Self("Main")
}

extension NSStoryboard.SceneIdentifier {
  static let mainWindow = Self("stringz.mainWindowController")
  static let mainViewController = Self("stringz.mainViewController")
  static let sidebarViewController = Self("stringz.sidebarViewController")
  static let editorViewController = Self("stringz.editorViewController")
  static let addStringViewController = Self("stringz.addStringViewController")
  static let wizardViewController = Self("stringz.wizardViewController")
}
