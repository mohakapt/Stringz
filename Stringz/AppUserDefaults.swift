//
//  AppPreferences.swift
//  Stringz
//
//  Created by Heysem Katibi on 1/18/17.
//  Copyright © 2017 Heysem Katibi. All rights reserved.
//

import Foundation
import Cocoa
import PathKit

enum SearchType: Int {
  case all
  case untranslated
  case translated
}

enum SearchScope: Int {
  case all
  case current
}

enum SearchField: Int {
  case key
  case comment
  case values
}

enum SearchMode: Int {
  case contains
  case startsWith
  case endsWith
  case regularExpression
}

extension UserDefaults {
  static let KeyHasOpenProjects = "stringz.hasOpenProjects"
  static let KeyShowKeyColumn = "stringz.showKeyColumn"
  static let KeyShowCommentColumn = "stringz.showCommentColumn"
  static let KeySelectedSegment = "stringz.selectedSegment"

  static let KeySearchType = "stringz.search.type"
  static let KeySearchScope = "stringz.search.scope"
  static let KeySearchFields = "stringz.search.fields"
  static let KeySearchMode = "stringz.search.mode"
  static let KeySearchMatchCase = "stringz.search.matchCase"
  static let KeySearchMatchWords = "stringz.search.matchWords"

  static let KeyGeneralAutosave = "stringz.general.autosave"
  static let KeyGeneralAutoload = "stringz.general.autoload"
  static let KeyGeneralAlwaysClearSearch = "stringz.general.alwyasClearSearch"
  static let KeyGeneralImmediatelySearch = "stringz.general.immediatelySearch"
  static let KeyGeneralShowUnlocalizedFiles = "stringz.general.showUnlocalizedFiles"
  static let KeyGeneralShowFlags = "stringz.general.showFlags"

  static let KeyImportingIgnoreEmpty = "stringz.importing.ignoreEmpty"
  static let KeyImportingIgnoreOnlyWhitespace = "stringz.importing.ignoreOnlyWhitespace"
  static let KeyImportingIgnoreUnusedInStoryboards = "stringz.importing.ignoreUnusedInStoryboards"
  static let KeyImportingIgnoreCommentsInStoryboards = "stringz.importing.ignoreCommentsInStoryboards"
  static let KeyImportingIgnoredValues = "stringz.importing.ignoredKeys"

  static let KeyExportingStringsOrder = "stringz.exporting.stringsOrder"
  static let KeyExportingCommentStyle = "stringz.exporting.commentStyle"
  static let KeyExportingEmptyLines = "stringz.exporting.emptyLines"

  static let KeyStoryboardXcodePath = "stringz.storyboard.xcodePath"

  static let KeyPlistImportAll = "stringz.plist.importAll"
  static let KeyPlistKeys = "stringz.plist.keys"

  static func clearAll() {
    let domain = Bundle.main.bundleIdentifier!
    standard.removePersistentDomain(forName: domain)
    standard.synchronize()
  }

  static func loadDefaults() {
    if !standard.bool(forKey: "stringz.didResetDefaults") {
      clearAll()
      standard.setValue(true, forKey: "stringz.didResetDefaults")
    }

    standard.register(defaults: [
      KeyHasOpenProjects: false,
      KeyShowKeyColumn: true,
      KeyShowCommentColumn: false,
      KeySelectedSegment: 0,

      KeySearchType: 0,
      KeySearchScope: 1,
      KeySearchFields: "0,2,",
      KeySearchMode: 0,
      KeySearchMatchCase: false,
      KeySearchMatchWords: false,

      KeyGeneralAutosave: true,
      KeyGeneralAutoload: true,
      KeyGeneralAlwaysClearSearch: true,
      KeyGeneralImmediatelySearch: true,
      KeyGeneralShowUnlocalizedFiles: false,
      KeyGeneralShowFlags: true,

      KeyImportingIgnoreEmpty: true,
      KeyImportingIgnoreOnlyWhitespace: false,
      KeyImportingIgnoreUnusedInStoryboards: false,

      KeyExportingStringsOrder: 0,
      KeyExportingCommentStyle: 1,
      KeyExportingEmptyLines: 2,

      KeyPlistImportAll: false,
    ])

    if storyboardXcodePath == nil {
      guard let xcodePath = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.dt.Xcode")?.path else {
        Common.alert(
          message: "You need to install Xcode for Stringz to work.",
          informative: "Stringz is using ibtool internally to parse localized storyboard and xib files.\n\nPlease install Xcode from https://developer.apple.com/xcode/resources/ or the App Store",
          positiveButton: "Quit") { response in
          switch (response) {
          default:
            exit(0)
            break
          }
        }
        return
      }

      let ibtoolPath = Path("\(xcodePath)/Contents/Developer/usr/bin/ibtool")
      if ibtoolPath.exists {
        storyboardXcodePath = xcodePath
      }
    } else {
      let ibtoolPath = Path("\(storyboardXcodePath!)/Contents/Developer/usr/bin/ibtool")
      if !ibtoolPath.exists {
        storyboardXcodePath = nil
      }
    }
  }
}

extension UserDefaults {
  static var hasOpenProjects: Bool {
    get { standard.bool(forKey: KeyHasOpenProjects) }
    set { standard.set(newValue, forKey: KeyHasOpenProjects) }
  }


  static var showKeyColumn: Bool {
    get { standard.bool(forKey: KeyShowKeyColumn) }
    set { standard.setValue(newValue, forKey: KeyShowKeyColumn) }
  }

  static var showCommentColumn: Bool {
    get { standard.bool(forKey: KeyShowCommentColumn) }
    set { standard.setValue(newValue, forKey: KeyShowCommentColumn) }
  }

  static var selectedSegment: Int {
    get { standard.integer(forKey: KeySelectedSegment) }
    set { standard.set(newValue, forKey: KeySelectedSegment) }
  }


  // MARK: - Search settings
  static var searchType: SearchType {
    get { SearchType(rawValue: standard.integer(forKey: KeySearchType))! }
    set { standard.setValue(newValue.rawValue, forKey: KeySearchType) }
  }

  static var searchScope: SearchScope {
    get { SearchScope(rawValue: standard.integer(forKey: KeySearchScope))! }
    set { standard.setValue(newValue.rawValue, forKey: KeySearchScope) }
  }

  static var searchFields: [SearchField] {
    get {
      let valueString = standard.string(forKey: KeySearchFields) ?? ""
      return valueString.components(separatedBy: ",").filter({ !$0.isEmpty }).map({ SearchField(rawValue: Int($0)!)! })
    }
    set {
      let valueString = newValue.reduce("") { $0 + String($1.rawValue) + "," }
      standard.setValue(valueString, forKey: KeySearchFields)
    }
  }

  static var searchMode: SearchMode {
    get { SearchMode(rawValue: standard.integer(forKey: KeySearchMode))! }
    set { standard.setValue(newValue.rawValue, forKey: KeySearchMode) }
  }

  static var searchMatchCase: Bool {
    get { standard.bool(forKey: KeySearchMatchCase) }
    set { standard.setValue(newValue, forKey: KeySearchMatchCase) }
  }

  static var searchMatchWords: Bool {
    get { standard.bool(forKey: KeySearchMatchWords) }
    set { standard.setValue(newValue, forKey: KeySearchMatchWords) }
  }


  // MARK: - General settings
  static var generalAutosave: Bool {
    get { standard.bool(forKey: KeyGeneralAutosave) }
    set { standard.setValue(newValue, forKey: KeyGeneralAutosave) }
  }

  static var generalAutoload: Bool {
    get { standard.bool(forKey: KeyGeneralAutoload) }
    set { standard.setValue(newValue, forKey: KeyGeneralAutoload) }
  }

  static var generalAlwaysClearSearch: Bool {
    get { standard.bool(forKey: KeyGeneralAlwaysClearSearch) }
    set { standard.setValue(newValue, forKey: KeyGeneralAlwaysClearSearch) }
  }

  static var generalImmediatelySearch: Bool {
    get { standard.bool(forKey: KeyGeneralImmediatelySearch) }
    set { standard.setValue(newValue, forKey: KeyGeneralImmediatelySearch) }
  }

  static var generalShowUnlocalizedFiles: Bool {
    get { standard.bool(forKey: KeyGeneralShowUnlocalizedFiles) }
    set { standard.setValue(newValue, forKey: KeyGeneralShowUnlocalizedFiles) }
  }

  static var generalShowFlags: Bool {
    get { standard.bool(forKey: KeyGeneralShowFlags) }
    set { standard.setValue(newValue, forKey: KeyGeneralShowFlags) }
  }


  // MARK: - Importing settings
  static var importingIgnoreEmpty: Bool {
    get { standard.bool(forKey: KeyImportingIgnoreEmpty) }
    set { standard.setValue(newValue, forKey: KeyImportingIgnoreEmpty) }
  }

  static var importingIgnoreOnlyWhitespace: Bool {
    get { standard.bool(forKey: KeyImportingIgnoreOnlyWhitespace) }
    set { standard.setValue(newValue, forKey: KeyImportingIgnoreOnlyWhitespace) }
  }

  static var importingIgnoreUnusedInStoryboards: Bool {
    get { standard.bool(forKey: KeyImportingIgnoreUnusedInStoryboards) }
    set { standard.setValue(newValue, forKey: KeyImportingIgnoreUnusedInStoryboards) }
  }

  static var importingIgnoreCommentsInStoryboards: Bool {
    get { standard.bool(forKey: KeyImportingIgnoreCommentsInStoryboards) }
    set { standard.setValue(newValue, forKey: KeyImportingIgnoreCommentsInStoryboards) }
  }

  static var importingDefaultIgnoredValues: [IgnoredValue] {
    return [IgnoredValue(uuid: UUID().uuidString, name: "Placeholder")]
  }

  static var importingIgnoredValues: [IgnoredValue] {
    get {
      if let data = standard.data(forKey: KeyImportingIgnoredValues),
         let array = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, IgnoredValue.self], from: data) as? [IgnoredValue] {
        return array
      } else {
        self.importingIgnoredValues = importingDefaultIgnoredValues
        return importingDefaultIgnoredValues
      }
    }
    set {
      let data = try? NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: false)
      standard.setValue(data, forKey: KeyImportingIgnoredValues)
    }
  }


  // MARK: - Exporting settings
  static var exportingStringsOrder: Int {
    get { standard.integer(forKey: KeyExportingStringsOrder) }
    set { standard.setValue(newValue, forKey: KeyExportingStringsOrder) }
  }

  static var exportingCommentStyle: Int {
    get { standard.integer(forKey: KeyExportingCommentStyle) }
    set { standard.setValue(newValue, forKey: KeyExportingCommentStyle) }
  }

  static var exportingEmptyLines: Int {
    get { standard.integer(forKey: KeyExportingEmptyLines) }
    set { standard.setValue(newValue, forKey: KeyExportingEmptyLines) }
  }


  // MARK: - Storyboard settings
  static var storyboardXcodePath: String? {
    get { standard.string(forKey: KeyStoryboardXcodePath) }
    set { standard.setValue(newValue, forKey: KeyStoryboardXcodePath) }
  }

  // MARK: - Plist settings
  static var plistImportAll: Bool {
    get { standard.bool(forKey: KeyPlistImportAll) }
    set { standard.setValue(newValue, forKey: KeyPlistImportAll) }
  }

  static var plistDefaultKeys: [PlistKey] {
    return plistDefaultDictionary.map { PlistKey(uuid: UUID().uuidString, name: $0.key, friendlyName: $0.value) }
  }

  static var plistKeys: [PlistKey] {
    get {
      if let data = standard.data(forKey: KeyPlistKeys),
         let array = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, PlistKey.self], from: data) as? [PlistKey] {
        return array
      } else {
        self.plistKeys = plistDefaultKeys
        return plistDefaultKeys
      }
    }
    set {
      let data = try? NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: false)
      standard.set(data, forKey: KeyPlistKeys)
    }
  }
}

fileprivate let plistDefaultDictionary = [
  "CFBundleDisplayName" : "Bundle display name",
  "CFBundleName" : "Bundle name",
  "CFBundleShortVersionString" : "Bundle versions string, short",
  "NFCReaderUsageDescription" : "Privacy - NFC Reader Usage Description",
  "NSAppleMusicUsageDescription" : "Privacy - Media Library Usage Description",
  "NSBluetoothPeripheralUsageDescription" : "Privacy - Bluetooth Peripheral Usage Description",
  "NSCalendarsUsageDescription" : "Privacy - Calendars Usage Description",
  "NSCameraUsageDescription" : "Privacy - Camera Usage Description",
  "NSContactsUsageDescription" : "Privacy - Contacts Usage Description",
  "NSFaceIDUsageDescription" : "Privacy - Face ID Usage Description",
  "NSHealthClinicalHealthRecordsShareUsageDescription" : "",
  "NSHealthShareUsageDescription" : "Privacy - Health Share Usage Description",
  "NSHealthUpdateUsageDescription" : "Privacy - Health Update Usage Description",
  "NSHomeKitUsageDescription" : "Privacy - HomeKit Usage Description",
  "NSHumanReadableCopyright" : "Copyright (human-readable)",
  "NSLocationAlwaysUsageDescription" : "Privacy - Location Always Usage Description",
  "NSLocationUsageDescription" : "Privacy - Location Usage Description",
  "NSLocationWhenInUseUsageDescription" : "Privacy - Location When In Use Usage Description",
  "NSMicrophoneUsageDescription" : "Privacy - Microphone Usage Description",
  "NSMotionUsageDescription" : "Privacy - Motion Usage Description",
  "NSPhotoLibraryAddUsageDescription" : "Privacy - Photo Library Additions Usage Description",
  "NSPhotoLibraryUsageDescription" : "Privacy - Photo Library Usage Description",
  "NSRemindersUsageDescription" : "Privacy - Reminders Usage Description",
  "NSSiriUsageDescription" : "",
  "NSSpeechRecognitionUsageDescription" : "",
  "NSVideoSubscriberAccountUsageDescription" : "Privacy - TV Provider Usage Description"
]
