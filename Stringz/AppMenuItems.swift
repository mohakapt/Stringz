//
//  AppMenuItems.swift
//  Stringz
//
//  Created by Heysem Katibi on 1.01.2021.
//

import Cocoa

extension NSUserInterfaceItemIdentifier {
  static let addLanguage = Self("stringz.addLanguage")
  static let addString = Self("stringz.addString")
  static let removeString = Self("stringz.removeString")

  static let showAll = Self("stringz.showAll")
  static let showUntranslated = Self("stringz.showUntranslated")
  static let showTranslated = Self("stringz.showTranslated")

  static let toggleKeyColumn = Self("stringz.toggleKeyColumn")
  static let toggleCommentColumn = Self("stringz.toggleCommentColumn")

  static let scopeAll = Self("stringz.scope.all")
  static let scopeCurrent = Self("stringz.scope.current")

  static let fieldsKey = Self("stringz.fields.key")
  static let fieldsComment = Self("stringz.fields.comment")
  static let fieldsValues = Self("stringz.fields.values")

  static let modeContains = Self("stringz.mode.contains")
  static let modeStartsWith = Self("stringz.mode.startsWith")
  static let modeEndsWith = Self("stringz.mode.endsWith")
  static let modeRegularExpression = Self("stringz.mode.regularExpression")

  static let optionsMatchCase = Self("stringz.options.matchCase")
  static let optionsMatchWords = Self("stringz.options.matchWords")

  static let find = Self("stringz.find")
  static let findAndReplace = Self("stringz.findAndReplace")
  static let findNext = Self("stringz.findNext")
  static let findPrevious = Self("stringz.findPrevious")
  static let findSelection = Self("stringz.findSelection")
  static let jumpToSelection = Self("stringz.jumpToSelection")
}
