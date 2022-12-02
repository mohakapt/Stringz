//
//  Localizable.swift
//  Stringz
//
//  Created by Heysem Katibi on 12/29/16.
//  Copyright © 2016 Heysem Katibi. All rights reserved.
//

import Foundation
import XcodeProj
import PathKit

/// Represents localizable object with all its languages and files.
/// A localizable object can contain one or more files depending on the number of supported languages,
/// Also, it has a type, for example, a storyboard, xib, strings, or config file.
class Localizable {
  let uuid = UUID()

  /// The name of the localizable group.
  let name: String

  /// The name of the parent of the localizable group.
  let parentName: String

  /// The files the localizable contains, Every file contains strings for a different language,
  /// So the number of files is the same number of supported languages in the localizable.
  var files: [File]

  /// The individual values the localizable contains,
  /// Those values are cross-joined from all the files of the localizable.
  var valueSets: [ValueSet]

  /// Determines whether the localizable is ready, loading, unloaded, or saving.
  /// If the status is unlocalized `files` array should contain only one file.
  var status: LocalizableStatus

  init(name: String, parentName: String, files: [File] = [], valueSets: [ValueSet] = [], status: LocalizableStatus = .unloaded) {
    self.name = name
    self.parentName = parentName
    self.files = files
    self.valueSets = valueSets
    self.status = status
  }
}

extension Localizable: Hashable {
  static func == (lhs: Localizable, rhs: Localizable) -> Bool {
    return lhs.uuid == rhs.uuid
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(uuid)
  }
}

extension Localizable: Comparable {
  static func < (lhs: Localizable, rhs: Localizable) -> Bool {
    return (lhs.localizableType, String(lhs.status == .unlocalized), lhs.name, lhs.parentName) < (rhs.localizableType, String(rhs.status == .unlocalized), rhs.name, rhs.parentName)
  }
}

extension Localizable {

  /// Returns all the values available in the localizable by language as a dictionary.
  func values(byLanguage lang: Language) -> [ValueHolder] {
    var reVal = [ValueHolder]()
    for valueSet in self.valueSets {
      if let value = valueSet.value(for: lang) {
        let baseIndex = valueSet.value(for: .base)?.originalIndex ?? valueSet.value(for: .english)?.originalIndex
        reVal.append(ValueHolder(key: valueSet.key, value: value.value, comment: valueSet.comment, variableName: value.variableName, originalIndex: value.originalIndex, baseIndex: baseIndex))
      }
    }
    return reVal
  }

  /// Returns the file that contains the given language in the localizable.
  func file(for language: Language) -> File? {
    return files.first { $0.language == language }
  }

  /// Returns all the supported languages in the current localizable.
  var languages: [Language] {
    var languages = files.map { $0.language }.uniqued().sorted(by: <)
    if languages.contains(.base) {
      languages.removeAll { $0 == .base }
      languages.insert(.base, at: 0)
    }
    return languages
  }

  /// Returns the total count of the strings in the current localizable.
  var totalCount: Int {
    return self.valueSets.count
  }

  /// Returns the values that don't have any missing strings in any of the supported languages in the current localizable.
  var translated: [ValueSet] {
    let langCount = languages.count
    return self.valueSets.filter { $0.values.filter { !$0.value.isEmpty }.count == langCount }
  }

  /// Returns the values that have some missing strings in one or all of the supported languages in the current localizable.
  var untranslated: [ValueSet] {
    let langCount = languages.count
    return self.valueSets.filter { $0.values.filter { !$0.value.isEmpty }.count < langCount }
  }

  /// Returns the total count of the untranslated strings in the current localizable.
  var untranslatedCount: Int {
    return untranslated.count
  }

  /// Returns the total count of the translated strings in the current localizable.
  var translatedCount: Int {
    return totalCount - untranslatedCount
  }

  /// Returns type of the current localizable, For example: storyboard, xib, string, or config file.
  var localizableType: LocalizableType {
    if files.contains(where: { $0.type == .storyboard }) {
      return .storyboard
    } else if files.contains(where: { $0.type == .xib }) {
      return .xib
    } else if files.contains(where: { $0.type == .config }) {
      return .config
    } else {
      return.strings
    }
  }

  /// Searches in the values of the current localizable for the given text query and value set type.
  func search(for type: SearchType, sortDescriptors: [NSSortDescriptor]) -> [ValueSet] {
    var valueSets: [ValueSet]

    switch type {
    case .untranslated:
      valueSets = self.untranslated
      break
    case .translated:
      valueSets = self.translated
      break

    default:
      valueSets = self.valueSets
      break
    }

    return valueSets.sorted(sortDescriptors: sortDescriptors)
  }
}

extension Array where Element == Localizable {

  /// Returns an array of localizables with the given localizable type.
  func filter(for type: LocalizableType, includeUnlocalized: Bool = true) -> [Localizable] {
    return self.filter { (includeUnlocalized || $0.status != .unlocalized) && $0.localizableType == type }
  }

  /// Return all available localizable types in the current array of localizable.
  func availableTypes(includeUnlocalized: Bool) -> [LocalizableType] {
    return LocalizableType.allCases.filter { self.filter(for: $0, includeUnlocalized: includeUnlocalized).count != 0 }
  }
}
