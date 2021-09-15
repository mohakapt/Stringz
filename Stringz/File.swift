//
//  File.swift
//  Stringz
//
//  Created by Heysem Katibi on 6.10.2020.
//

import Foundation
import PathKit

/// Represents the file that holds the translations for a language on the disk drive.
class File {
  /// The uuid of the file in the xcode project.
  ///
  /// This id is extremely important to find the file reference in the xcode project.
  let uuid: String

  /// The type of the file. storyboard, xib, strings or config file.
  let type: LocalizableType

  /// The language of the string the file contains.
  let language: Language

  /// The physical path of the file on the disk drive.
  let path: Path

  /// The physical path of the project containing the file on the disk drive.
  let projectPath: Path

  /// Extra information to attach to the file
  var extras: [String: Any] = [:]

  init(uuid: String, type: LocalizableType, language: Language, path: Path, projectPath: Path) {
    self.uuid = uuid
    self.type = type
    self.language = language
    self.path = path
    self.projectPath = projectPath
  }
}

extension File: Hashable {
  static func == (lhs: File, rhs: File) -> Bool {
    return lhs.uuid == rhs.uuid
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(uuid)
  }
}

extension File{

  /// The uuids of the corresponding xcode native targets that the file belongs to..
  ///
  /// This is is useful when adding new files to the project because we want to add the new file to the same targets as the old one.
  var targetsUuids: [String] {
    get {
      return extras["targetsUuids"] as? [String] ?? []
    }
    set {
      extras["targetsUuids"] = newValue
    }
  }

  /// the uuid of the corresponding xcode configuration that the file belongs to.
  ///
  /// This is is useful when importing .plist files from the project.
  var configurationUuid: String? {
    get {
      return extras["configurationUuid"] as? String
    }
    set {
      extras["configurationUuid"] = newValue
    }
  }
}
