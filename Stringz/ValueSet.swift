//
//  ValueSet.swift
//  Stringz
//
//  Created by Heysem Katibi on 12/30/16.
//  Copyright © 2016 Heysem Katibi. All rights reserved.
//

import Foundation

/// Represents a set of translations for the same string.
///
/// For example a ValueSet with key "cancel" can have an english value of "Cancel"
/// and a german value of "Cancel" and a Japanese value of "キャンセル" and so on.
class ValueSet {
  let uuid = UUID()

  /// The key of the value set
  var key: String

  /// A comment to describe the values in this set.
  ///
  /// This comment doen't show for users on the UI, It's only used to help developers remember where they should use the value set.
  var comment: String = ""

  /// The different translations for the string value, contains as many translations as the localizable supports.
  var values: [Value] = []

  /// Extra information to attach to the value set
  var extras: [String: Any] = [:]

  init(key: String) {
    self.key = key
  }
}

extension ValueSet: Equatable, Hashable {
  static func == (lhs: ValueSet, rhs: ValueSet) -> Bool {
    return lhs.uuid == rhs.uuid
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(uuid)
  }
}

extension ValueSet {
  /// Updates the translation value for given language.
  ///
  /// Might create a new translation if the given  langauge doesn't exist in the value set.
  /// - Parameter value: The new value to be set.
  /// - Parameter language: The langauge of the value.
  func setOrAppend(value: String, for language: Language) {
    if let val = self.value(for: language) {
      val.value = value
    } else {
      values.append(Value(language: language, value: value))
    }
  }

  /// Updates the translation value for a value given its language.
  ///
  /// This function does nothing if a value with the given langauge doesn't exist in the value set.
  /// - Parameter value: The new value to be set.
  /// - Parameter language: The langauge of the value.
  func set(value: String, for language: Language) {
    if let val = self.value(for: language) {
      val.value = value
    }
  }

  /// Updates the original index for a value given its language.
  ///
  /// This function does nothing if a value with the given langauge doesn't exist in the value set.
  /// - Parameter originalIndex: The original index of the value.
  /// - Parameter language: The langauge of the value.
  func set(originalIndex: Int?, for language: Language) {
    if let val = self.value(for: language) {
      val.originalIndex = originalIndex
    }
  }

  /// Updates the variable name in value set for given language.
  ///
  /// This function does nothing if langauge doesn't exist in the value set.
  /// - Parameter variableName: The variable name to be set.
  /// - Parameter language: The langauge of the value.
  func set(variableName: String?, for language: Language) {
    if let val = self.value(for: language) {
      val.variableName = variableName
    }
  }

  /// Finds the translation value for given language
  /// - Parameter language: The language to use to find translation in.
  /// - Returns: The value for given langauge, nil if the language doen't exist.
  func value(for language: Language) -> Value? {
    return values.value(for: language)
  }

  /// Returns all available languages in current value set
  var availableLanguages: [Language] {
    return self.values.map { $0.language }.uniqued()
  }
}

extension Array where Element == ValueSet {
  /// Updates the translation of a string value given its key and the language.
  ///
  /// Might create a new value if the given key of langauge doesn't exist.
  /// - Parameter value: The new value to be set.
  /// - Parameter key: The key of the value set.
  /// - Parameter language: The langauge of the value.
  /// - Returns: The value set that was updated or appended.
  mutating func setOrAppend(value: String, for key: String, and language: Language) -> ValueSet {
    var valueSet = self.first(where: { $0.key == key })

    if valueSet == nil {
      valueSet = ValueSet(key: key)
      self.append(valueSet!)
    }

    valueSet!.setOrAppend(value: value, for: language)
    return valueSet!
  }

  /// Updates the translation of a value given its key and language.
  ///
  /// This method does nothing if value set with the given key or language doesn't exist.
  /// - Parameter value: The new value to be set.
  /// - Parameter key: The key of the value set.
  /// - Parameter language: The langauge of the value.
  mutating func set(value: String, for key: String, and language: Language) {
    if let valueSet = self.valueSet(for: key) {
      valueSet.set(value: value, for: language)
    }
  }

  /// Updates the comment value of a string given its key
  ///
  /// This method does nothing if values set with the given key doesn't exist.
  /// - Parameter comment: A comment to set to the value set.
  /// - Parameter key: The key of the value set.
  mutating func set(comment: String, for key: String) {
    if let valueSet = self.valueSet(for: key) {
      valueSet.comment = comment
    }
  }

  /// Updates original index of a value given its key and language.
  ///
  /// This method does nothing if values set with the given key or language doesn't exist.
  /// - Parameter originalIndex: The original index of the value.
  /// - Parameter key: The key of the value set.
  /// - Parameter language: The langauge of the value.
  mutating func set(originalIndex: Int?, for key: String, and language: Language) {
    if let valueSet = self.valueSet(for: key) {
      valueSet.set(originalIndex: originalIndex, for: language)
    }
  }

  /// Updates variable name of a string given its key and language.
  ///
  /// This method does nothing if values set with the given key or language doesn't exist.
  /// - Parameter variableName: The variable name of info plist value of the value set.
  /// - Parameter key: The key of the value set.
  /// - Parameter language: The langauge of the value.
  mutating func set(variableName: String?, for key: String, and language: Language) {
    if let valueSet = self.valueSet(for: key) {
      valueSet.set(variableName: variableName, for: language)
    }
  }

//  /// Finds the comment for value set given its key
//  /// - Parameter key: The key of the value set.
//  /// - Returns: The comment for value set, nil if the key doen't exist.
//  func comment(for key: String) -> String? {
//    return self.first(where: { $0.key == key })?.comment
//  }

  func contains(key: String) -> Bool {
    return valueSet(for: key) != nil
  }

  func valueSet(for key: String) -> ValueSet? {
    return first(where: { $0.key == key })
  }

  /// Returns all available languages in current value set array
  var availableLanguages: [Language] {
    return self.flatMap { $0.availableLanguages }.uniqued()
  }
}
