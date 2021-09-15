//
//  Value.swift
//  Stringz
//
//  Created by Heysem Katibi on 12/26/16.
//  Copyright © 2016 Heysem Katibi. All rights reserved.
//

import Foundation

/// Represents a value from a specific language with its key and comment.
///
/// This type is useful when saving files to the drive disk where we need the key, value and comment values for a  particular language.
struct ValueHolder {
  let key: String
  let value: String
  let comment: String
  let variableName: String?

  let originalIndex: Int?
  let baseIndex: Int?
}

/// Represents an individual string inside a localizable file,
/// This string should be in the same langauge as the file it comes from.
class Value {
  let uuid = UUID()

  /// The langauge of the localizable string.
  let language: Language

  /// The value of the localizable string.
  var value: String

  /// Contains the name of the variable that holdes the string value
  /// This is mostly used for .plist files where the string values are stored in the configuration of the Xcode project
  /// then referenced from within the .plist file. Could be nil if the value is written directly without a variable.
  var variableName: String?

  /// The order of the value in its original file
  var originalIndex: Int?

  /// Extra information to attach to the value
  var extras: [String: Any] = [:]

  init(language: Language, value: String) {
    self.language = language
    self.value = value
  }
}

extension Value: Hashable {
  static func == (lhs: Value, rhs: Value) -> Bool {
    return lhs.uuid == rhs.uuid
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(uuid)
  }
}

extension Array where Element == Value {
  func value(for language: Language) -> Value? {
    return first(where: { $0.language == language })
  }
}
