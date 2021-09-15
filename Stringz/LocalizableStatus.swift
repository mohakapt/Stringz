//
//  LocalizableStatus.swift
//  Stringz
//
//  Created by Heysem Katibi on 21.12.2020.
//

import Foundation

/// Represents the current status of the localizable
enum LocalizableStatus: Int, CaseIterable {
  case ready
  case unloaded
  case unlocalized
  case loading
  case saving
}
