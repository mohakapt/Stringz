//
//  LocalizableType.swift
//  Stringz
//
//  Created by Heysem Katibi on 29.11.2020.
//

import Foundation

/// Represents the type of a localizable group.
///
/// It's importent to determine the type of the localizable because fetching and saving strings is different for different localizable types.
enum LocalizableType: Int, CaseIterable {
  case strings
  case storyboard
  case xib
  case config
}

extension LocalizableType: Comparable {
  static func < (lhs: LocalizableType, rhs: LocalizableType) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }
}
