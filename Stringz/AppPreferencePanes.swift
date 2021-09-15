//
//  AppPreferencePanes.swift
//  Stringz
//
//  Created by Heysem Katibi on 21.12.2020.
//

import Foundation
import Preferences

extension Preferences.PaneIdentifier {
  static let general = Self("stringz.general")
  static let plist = Self("stringz.plist")
  static let importing = Self("stringz.importing")
  static let exporting = Self("stringz.exporting")
  static let xib = Self("stringz.xib")
  static let advanced = Self("stringz.advanced")
}
