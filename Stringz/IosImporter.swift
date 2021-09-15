//
//  IosImporter.swift
//  Stringz
//
//  Created by Heysem Katibi on 12/29/16.
//  Copyright © 2016 Heysem Katibi. All rights reserved.
//

import Foundation
import XcodeProj
import PathKit

class IosImporter {
  /// Finds string values in *.strings files, This expression also match any comments the string might have.
  static let findStringWithCommentExpression =
    "("
    + findInlineCommentExpression + "*"
    + findPrologueCommentExpression + "*"
    + findInlineCommentExpression + "*"
    + ")"
    + "?"
    + findStringExpression

  /// Matches only string values in given *.strings file, Matches any whitespaces exsiting in between the values but doen't match any comments.
  static let findStringExpression = #"("[^\"]*"\s*=\s*".+?"\s*;)"#
  /// Matches all unnecessary whitespaces the value might have, Can be used to clean the value.
  static let cleanStringExpression = #""\s*=\s*""#

  static let findInlineCommentExpression = #"(\/\/.*(\n\s*?))"#
  static let findPrologueCommentExpression = #"(\/\*(.|\n)*?\*\/(\n\s*?)*)"#

  /// Matches only comment values in given *.strings file, Matches any whitespaces exsiting in between the comments but doen't match any values.
  static let findCommentExpression = findInlineCommentExpression + "|" + findPrologueCommentExpression
  /// Matches all unnecessary whitespaces the comment might have, Can be used to clean the comment.
  static let cleanCommentExpression = #"(\/\*\s*)|(\s*\*\/)|(\/\/\s*)"#
  /// Matches an auto generated comment in storyboards
  static let storyboardCommentExpression = #"(?i)^.*class(\s*)?=(\s*)?.*objectid(\s*)?=(\s*)?.*;.*$"#

  /// Matches variable values in info plist files
  static let findVariableExpression = #"(?<=\$\().*(?=\))"#
  /// Matches the project project root variable in the path of info plist files,
  static let cleanInfoPlistPathExpression = #"\$?\(.*\)\/?"#


  static func loadProject(from projectPath: Path, with options: inout ImporterOptions) -> [Localizable] {
    guard let xcodeProject = try? XcodeProj(path: projectPath) else { return [] }

    let variantGroups = xcodeProject.pbxproj.variantGroups
    let fileReferences = xcodeProject.pbxproj.fileReferences
    let nativeTargets = xcodeProject.pbxproj.nativeTargets

    // Importing localized files
    var localizables = [Localizable]()
    for group in variantGroups {
      guard let name = group.name, group.children.count > 0 else { continue }
      guard name.localizedCaseInsensitiveContains("plist.strings") == false else { continue }
      let parentName = group.parent?.path ?? group.parent?.name ?? ""

      let files = IosImporter.files(in: group, relativeTo: projectPath, with: nativeTargets)
      guard files.count > 0 else { continue }
      let localizable = Localizable(name: name, parentName: parentName, files: files)
      localizables.append(localizable)
    }

    // Importing unlocalized files
    let importedFiles = localizables.flatMap { $0.files }
    let remainingFiles = fileReferences
      .filter { fileReference in
        guard
          !importedFiles.contains(where: { $0.uuid == fileReference.uuid }),
          !(fileReference.path?.localizedCaseInsensitiveContains("Plist.strings") == true),
          !(fileReference.path?.localizedCaseInsensitiveContains(".lproj") == true)
        else { return false }

        let fileType = fileReference.fileType
        return fileType == .strings || fileType == .storyboard || fileType == .xib
      }

    for fileReference in remainingFiles {
      guard
        let name = fileReference.path,
        let file = IosImporter.file(from: fileReference, relativeTo: projectPath, with: nativeTargets, defaultLanguage: .base)
      else { continue }
      let parentName = fileReference.parent?.path ?? fileReference.parent?.name ?? ""

      let localizable = Localizable(name: name, parentName: parentName, files: [file], status: .unlocalized)
      localizables.append(localizable)
    }

    // Importing config files
    let plistFileReferences = fileReferences.filter { $0.fileType == .plist }
    var plistNames = [String]()

    for nativeTarget in nativeTargets {
      guard let configurations = nativeTarget.buildConfigurationList?.buildConfigurations else { continue }

      for configuration in configurations {
        guard var plistName = configuration.buildSettings["INFOPLIST_FILE"] as? String, !plistName.isEmpty else { continue }
        plistName = RegEx.replace(plistName, with: "", using: IosImporter.cleanInfoPlistPathExpression)
        guard !plistNames.contains(plistName) else { continue }
        plistNames.append(plistName)

        let plistPath = projectPath.parent() + Path(stringLiteral: plistName)
        guard let plistFileReference = plistFileReferences.first(where: { (try? $0.fullPath(sourceRoot: projectPath.parent())) == plistPath }) else { continue }
        guard let plistFile = IosImporter.file(from: plistFileReference, relativeTo: projectPath, with: nativeTargets, defaultLanguage: .base) else { continue }
        guard let name = plistFileReference.path else { continue }
        let parentName = plistFileReference.parent?.path ?? plistFileReference.parent?.name ?? ""

        let infoPlistFile = File(uuid: plistFile.uuid, type: plistFile.type, language: plistFile.language, path: plistFile.path, projectPath: plistFile.projectPath)
        infoPlistFile.targetsUuids = [nativeTarget.uuid]
        infoPlistFile.configurationUuid = configuration.uuid
        var files = [infoPlistFile]

        if var targetFiles = try? nativeTarget.resourcesBuildPhase()?.files {
          targetFiles = targetFiles.filter { $0.file?.name?.caseInsensitiveCompare("InfoPlist.strings") == .orderedSame }

          if let variantGroup = targetFiles.first?.file as? PBXVariantGroup {
            let filez = IosImporter.files(in: variantGroup, relativeTo: projectPath, with: nativeTargets)
            files.append(contentsOf: filez)
          }
        }

        //        for file in files.sorted(by: { $0.type < $1.type }) {
        //          let values = IosImporter.values(in: file, with: options, and: configuration.buildSettings)
        //
        //          for val in values {
        //            let key = val.key
        //            valueSets.set(value: val.value, with: val.originalIndex, and: key, for: file.language)
        //            valueSets.set(variableName: val.variableName, with: key, for: file.language)
        //
        //            if valueSets.comment(for: key)?.isEmpty != false, let comment = val.comment {
        //              valueSets.set(comment: comment, with: key)
        //            }
        //
        //            // Add new keys
        //            options.plistKeys.appendIfDoesntExist(key)
        //          }
        //        }

        let localizable = Localizable(name: name, parentName: parentName, files: files)
        localizables.append(localizable)
      }
    }

    return localizables
  }

  static func file(from fileReference: PBXFileReference, relativeTo projectPath: Path, with targets: [PBXNativeTarget], defaultLanguage: Language? = nil) -> File? {
    guard
      let fileType = IosImporter.type(for: fileReference),
      let fileLanguage = IosImporter.language(for: fileReference, defaultLanguage: defaultLanguage),
      let filePath = IosImporter.path(for: fileReference, in: projectPath)
    else { return nil }

    let fileTargets = IosImporter.targets(for: fileReference, using: targets)
    let targetsUuids = fileTargets.map { $0.uuid }

    let file = File(uuid: fileReference.uuid, type: fileType, language: fileLanguage, path: filePath, projectPath: projectPath)
    file.targetsUuids = targetsUuids
    return file
  }

  static func files(in group: PBXVariantGroup, relativeTo projectPath: Path, with targets: [PBXNativeTarget]) -> [File] {
    var files = [File]()

    for child in group.children {
      guard let fileReference = child as? PBXFileReference,
            let file = IosImporter.file(from: fileReference, relativeTo: projectPath, with: targets)
      else { continue }

      files.append(file)
    }

    return files
  }

  static func path(for file: PBXFileReference, in projectPath: Path) -> Path? {
    let trimPath = { (path: Path) -> Path in
      var components = path.components
      components.remove(at: components.count - 4)
      components.remove(at: components.count - 3)
      return Path(components: components)
    }

    guard let path = try? file.fullPath(sourceRoot: projectPath.parent()) else { return nil }

    if path.components.filter({ $0.localizedCaseInsensitiveContains(".lproj") }).count > 1 {
      return trimPath(path)
    } else {
      return path
    }
  }

  static func type(for file: PBXFileReference) -> LocalizableType? {
    switch file.fileType {
    case .strings: return .strings
    case .storyboard: return .storyboard
    case .xib: return .xib
    case .plist: return .config
    default: return nil
    }
  }

  static func targets(for file: PBXFileReference, using targets: [PBXNativeTarget]) -> [PBXNativeTarget] {
    return targets.filter { target in
      guard let buildFiles = try? target.resourcesBuildPhase()?.files else { return false }
      return buildFiles.contains { buildFile in
        if buildFile.file?.uuid == file.uuid {
          return true
        }
        if let variantGroup = buildFile.file as? PBXVariantGroup {
          return variantGroup.children.contains { fileReference in
            fileReference.uuid == file.uuid
          }
        }
        return false
      }
    }
  }

  static func language(for file: PBXFileReference, defaultLanguage: Language? = nil) -> Language? {
    guard let name = file.name else { return defaultLanguage }
    return Language(rawValue: name.lowercased()) ?? defaultLanguage
  }

  static func values(in file: File, with options: ImporterOptions, and buildSettings: BuildSettings? = nil) -> [ValueHolder] {
    switch file.type {
    case .storyboard, .xib:
      return IosImporter.valuesInStoryboard(in: file.path, with: options)
    case .strings:
      return IosImporter.valuesInStrings(in: file.path, with: options)
    case .config:
      return IosImporter.valuesInInfoPlist(in: file.path, with: options, and: buildSettings)
    }
  }

  private static func valuesInStrings(in path: Path, with options: ImporterOptions) -> [ValueHolder] {
    let content = IosImporter.readContent(path: path)
    var reVal = [ValueHolder]()

    let resources = RegEx.matches(for: IosImporter.findStringWithCommentExpression, in: content)
    for (index, var res) in resources.enumerated() {
      var comment = ""
      let comments = RegEx.matches(for: IosImporter.findCommentExpression, in: res)
      for cmnt in comments {
        comment += cmnt
        res = res.replacingOccurrences(of: cmnt, with: "")
      }

      guard var string = RegEx.matches(for: IosImporter.findStringExpression, in: res).first else { continue }

      string = RegEx.replace(string, with: "\"=\"", using: IosImporter.cleanStringExpression)
        .trimmingCharacters(in: .whitespaces)
        .trimmingCharacters(in: [";"])

      let vals = string.components(separatedBy: "=")

      let key = String(vals[0]
        .trimmingCharacters(in: .whitespaces)
        .dropFirst().dropLast())
      if key.isEmpty { continue }

      let value = String(vals[1]
        .trimmingCharacters(in: .whitespaces)
        .dropFirst().dropLast())

      if options.ignoreEmptyValues && value.isEmpty { continue }
      if options.ignoreOnlyWhitespaceValues && value.trimmingCharacters(in: .whitespaces).isEmpty { continue }
      if options.ignoredValues.contains(where: { $0.name.localizedCaseInsensitiveCompare(value) == .orderedSame }) { continue }

      if options.ignoreCommentsInStoryboards, !RegEx.matches(for: IosImporter.storyboardCommentExpression, in: comment).isEmpty {
      } else {
        comment = RegEx.replace(comment, with: "", using: IosImporter.cleanCommentExpression)
        comment = comment.trimmingCharacters(in: .newlines)
      }

      reVal.append(ValueHolder(key: key, value: value, comment: comment, variableName: nil, originalIndex: index, baseIndex: nil))
    }

    return reVal
  }

  private static func valuesInStoryboard(in path: Path, with options: ImporterOptions) -> [ValueHolder] {
    guard let xcodePath = options.xcodePath else { return [] }
    let ibtool = Path(stringLiteral: "\(xcodePath)/Contents/Developer/usr/bin/ibtool")
    guard ibtool.exists else { return [] }

    let tempPath = path.parent() + "temp.strings"
    Process.launchedProcess(launchPath: ibtool.string, arguments: [path.string, "--generate-strings-file", tempPath.string]).waitUntilExit()
    let reVal = IosImporter.valuesInStrings(in: tempPath, with: options)

    do {
      try tempPath.delete()
    } catch {
      // ToDo: Send error report to AppCenter
    }
    return reVal
  }

  private static func valuesInInfoPlist(in path: Path, with options: ImporterOptions, and buildSettings: BuildSettings? = nil) -> [ValueHolder] {
    var plist: [String: Any]
    do {
      let data = try IosImporter.read(path: path)
      plist = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil) as! [String: Any]
    } catch {
      // ToDo: Send error report to AppCenter
      return []
    }

    let resources = plist.filter { resource in
      if options.importAllPlistKeys {
        return (resource.value as? String) != nil
      } else {
        return options.plistKeys.contains { $0.name == resource.key }
      }
    }

    var reVal: [ValueHolder] = []
    for (index, res) in resources.enumerated() {
      guard var value = res.value as? String else { continue }
      let variableName = RegEx.matches(for: IosImporter.findVariableExpression, in: value).first
      if let buildSettings = buildSettings, let variableName = variableName, let newValue = buildSettings[variableName] as? String {
        value = newValue
      }

      reVal.append(ValueHolder(key: res.key, value: value, comment: "", variableName: variableName, originalIndex: index, baseIndex: nil))
    }

    return reVal
  }

  static func addLanguage(_ language: Language, to name: String, with data: Data, in projectPath: Path) -> File? {
    guard let xcodeProject = try? XcodeProj(path: projectPath) else { return nil }
    guard let variantGroup = xcodeProject.pbxproj.variantGroups.first(where: { $0.name == name }) else { return nil }
    let fileName = name.replacingOccurrences(of: ".storyboard", with: ".strings").replacingOccurrences(of: ".xib", with: ".strings")

    do {
      guard var filePath = try variantGroup.fullPath(sourceRoot: projectPath.parent()) else { return nil }
      filePath = filePath + Path(components: ["\(language.rawValue).lproj", fileName])

      let fileReference = try variantGroup.addFile(at: filePath, sourceRoot: projectPath.parent(), validatePresence: false)
      fileReference.name = language.rawValue

      if let actualPath = IosImporter.path(for: fileReference, in: projectPath) {
        try actualPath.parent().mkpath()
        try actualPath.write(data)
        try xcodeProject.write(path: projectPath)

        return IosImporter.file(from: fileReference, relativeTo: projectPath, with: xcodeProject.pbxproj.nativeTargets)
      }
    } catch {
    }

    return nil
  }

  static func removeLanguage(file: File, in projectPath: Path) -> Data? {
    guard
      let xcodeProject = try? XcodeProj(path: projectPath),
      let variantGroup = xcodeProject.pbxproj.variantGroups.first(where: { $0.children.contains(where: { $0.uuid == file.uuid }) }),
      let fileReference = variantGroup.children.first(where: { $0.uuid == file.uuid }) as? PBXFileReference,
      let actualPath = IosImporter.path(for: fileReference, in: projectPath)
    else { return nil }

    do {
      let data = try actualPath.read()
      try actualPath.delete()

      xcodeProject.pbxproj.delete(object: fileReference)
      variantGroup.children.removeAll(where: { $0.uuid == fileReference.uuid })
      try xcodeProject.write(path: projectPath)

      return data
    } catch {
    }

    return nil
  }

  private static func saveStoryboard(file: File, values: [ValueHolder], with options: ImporterOptions) {
    guard file.type == .storyboard || file.type == .xib else { return }

    var content = IosImporter.readContent(path: file.path)
    let lines = content.split(separator: "\n")

    values.forEach { res in
      let components = res.key.split(separator: ".")
      guard let line = lines.first(where: { $0.contains("id=\"\(components[0])\"") }) else { return }
      let newLine = RegEx.replace(String(line), with: "\(components[1])=\"\(res.value)\"", using: "\(components[1])=\"(.*?)\"")

      content = content.replacingOccurrences(of: line, with: newLine)
    }

    IosImporter.write(content: content, to: file.path)
  }

  private static func saveStrings(file: File, values: [ValueHolder], with options: ImporterOptions) {
    guard file.type == .strings else { return }

    var content = ""
    let newValues = values.sorted { (lhs, rhs) in
      switch options.exportOrder {
      case .sameAsOriginal:
        return lhs.originalIndex ?? 999999 < rhs.originalIndex ?? 999999
      case .sameAsBase:
        return lhs.baseIndex ?? 999999 < rhs.baseIndex ?? 999999
      case .alphabeticallyAscending:
        return lhs.key < rhs.key
      case .alphabeticallyDescending:
        return lhs.key > rhs.key
      }
    }
    newValues.forEach { res in
      guard !res.value.isEmpty else { return }
      if !res.comment.isEmpty {
        if options.emptyLines == .beforeComments {
          content += "\n"
        }

        if options.commentStyle == .block {
          content += "/* \(res.comment) */"
        } else {
          content += "// \(res.comment.replacingOccurrences(of: "\n", with: "\n// "))"
        }

        content += "\n"
      }
      content += "\"\(res.key)\" = \"\(res.value)\";"
      content += "\n"

      if options.emptyLines == .always {
        content += "\n"
      }
    }
    content = content.trimmingCharacters(in: .newlines)
    content += "\n"


    IosImporter.write(content: content, to: file.path)
  }

  private static func saveInfoPlist(file: File, values: [ValueHolder], with options: ImporterOptions) {
    var plist: [String: Any]
    do {
      let data = try IosImporter.read(path: file.path)
      plist = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil) as! [String: Any]
    } catch {
      // ToDo: Send error report to AppCenter
      return
    }

    let originalValues = IosImporter.values(in: file, with: options)
    let valuesToRemove = originalValues.filter { originalValue in !values.contains { value in value.key == originalValue.key } }

    valuesToRemove.forEach { value in
      plist.removeValue(forKey: value.key)
    }
    values.forEach { value in
      plist[value.key] = value.variableName == nil ? value.value : "$(\(value.variableName!))"
    }

    guard let newData = try? PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: .bitWidth) else { return }
    try? file.path.write(newData)

    guard let xcodeProject = try? XcodeProj(path: file.projectPath) else { return }
    let nativeTargets = xcodeProject.pbxproj.nativeTargets.filter { file.targetsUuids.contains($0.uuid) && $0.buildConfigurationList != nil }
    let configurations = nativeTargets.flatMap { $0.buildConfigurationList!.buildConfigurations }

    configurations.forEach { configuration in
      valuesToRemove.filter({ $0.variableName != nil }).forEach { value in
        configuration.buildSettings.removeValue(forKey: value.variableName!)
      }
      values.filter({ $0.variableName != nil }).forEach { value in
        configuration.buildSettings[value.variableName!] = value.value
      }
    }

    try? xcodeProject.write(path: file.projectPath)
  }

  static func save(file: File, values: [ValueHolder], with options: ImporterOptions) {
    switch file.type {
    case .storyboard, .xib:
      IosImporter.saveStoryboard(file: file, values: values, with: options)
      break
    case .config:
      IosImporter.saveInfoPlist(file: file, values: values, with: options)
      break
    case .strings:
      IosImporter.saveStrings(file: file, values: values, with: options)
      break
    }
  }

  static func localize(_ localizable: inout Localizable, in projectPath: Path) throws {
    guard let file = localizable.files.first else { throw StringzError.importerError("localize", message: "unable to localize this localizable because it doesn't have any files") }

    let xcodeProject = try XcodeProj(path: projectPath)
    let fileReferences = xcodeProject.pbxproj.fileReferences
    let nativeTargets = xcodeProject.pbxproj.nativeTargets

    guard
      let originalFile = fileReferences.first(where: { $0.uuid == file.uuid }),
      let fileName = originalFile.path,
      let parentGroup = originalFile.parent as? PBXGroup
    else { throw StringzError.importerError("localize", message: "unable to get file's info") }

    // - Remove old file from the project
    guard let originalIndex = parentGroup.children.firstIndex(of: originalFile) else { throw StringzError.importerError("localize", message: "unable to find file index in the project") }
    parentGroup.children.removeAll(where: { $0.uuid == file.uuid })
    xcodeProject.pbxproj.delete(object: originalFile)

    nativeTargets.forEach { target in
      guard let buildPhase = try? target.resourcesBuildPhase() else { return }
      buildPhase.files?.removeAll(where: { $0.file?.uuid == file.uuid })
    }

    // - Move file to new destination
    let destinationPath = file.path.parent() + Path(components: ["Base.lproj", file.path.lastComponent])
    try destinationPath.parent().mkpath()
    try file.path.move(destinationPath)

    // - Add new file to the project
    let variantGroup = try parentGroup.addVariantGroup(named: fileName).first!
    let fileReference = try variantGroup.addFile(at: destinationPath, sourceRoot: destinationPath.parent().parent().parent())

    fileReference.name = "Base"
    fileReference.fileEncoding = originalFile.fileEncoding
    fileReference.explicitFileType = originalFile.explicitFileType
    fileReference.lastKnownFileType = originalFile.lastKnownFileType
    let item = parentGroup.children.removeLast()
    parentGroup.children.insert(item, at: originalIndex)

    // - Add new file to old file's targets
    file.targetsUuids.forEach { targetUUid in
      guard
        let target = nativeTargets.first(where: { $0.uuid == targetUUid }),
        let buildPhase = try? target.resourcesBuildPhase()
      else { return }

      let _ = try! buildPhase.add(file: variantGroup)
    }

    try xcodeProject.write(path: projectPath)

    // - Import localizations from file
    let files = IosImporter.files(in: variantGroup, relativeTo: projectPath, with: nativeTargets)

    localizable.files.removeAll()
    localizable.files.append(contentsOf: files)
    localizable.status = .unloaded
  }

  static func unlocalize(_ localizable: inout Localizable, in projectPath: Path) throws {
    guard let file = localizable.file(for: .base) ?? localizable.file(for: .english) ?? localizable.files.first else { throw StringzError.importerError("unlocalize", message: "unable to find the original file") }

    let xcodeProject = try XcodeProj(path: projectPath)
    let fileReferences = xcodeProject.pbxproj.fileReferences
    let varientGroups = xcodeProject.pbxproj.variantGroups
    let nativeTargets = xcodeProject.pbxproj.nativeTargets

    guard let variantGroup = varientGroups.first(where: { $0.children.contains(where: { $0.uuid == file.uuid }) }) else { throw StringzError.importerError("unlocalize", message: "unable to find file's variant group") }
    guard
      let originalFile = fileReferences.first(where: { $0.uuid == file.uuid }),
      let parentGroup = variantGroup.parent as? PBXGroup
    else { throw StringzError.importerError("unlocalize", message: "unable to get file's info") }

    // - Remove new file from the project
    guard let originalIndex = parentGroup.children.firstIndex(of: variantGroup) else { throw StringzError.importerError("unlocalize", message: "unable to find variant group index in the project") }
    parentGroup.children.removeAll { $0.uuid == variantGroup.uuid }
    localizable.files.forEach { file in
      guard let fileReference = fileReferences.first(where: { $0.uuid == file.uuid }) else { return }
      xcodeProject.pbxproj.delete(object: fileReference)
    }
    xcodeProject.pbxproj.delete(object: variantGroup)
    nativeTargets.forEach { target in
      guard let buildPhase = try? target.resourcesBuildPhase() else { return }
      buildPhase.files?.removeAll { $0.file?.uuid == variantGroup.uuid }
    }

    // - Move file to old destination
    let components = file.path.components.filter { !$0.localizedCaseInsensitiveContains(".lproj") }
    let destinationPath = Path(components: components)
    try destinationPath.parent().mkpath()
    try file.path.move(destinationPath)

    // - Add old file to the project
    let fileReference = try parentGroup.addFile(at: destinationPath, sourceRoot: projectPath.parent())
    fileReference.fileEncoding = originalFile.fileEncoding
    fileReference.explicitFileType = originalFile.explicitFileType
    fileReference.lastKnownFileType = originalFile.lastKnownFileType
    fileReference.name = nil
    let item = parentGroup.children.removeLast()
    parentGroup.children.insert(item, at: originalIndex)

    // - Add new file to old file's targets
    file.targetsUuids.forEach { targetUUid in
      guard
        let target = nativeTargets.first(where: { $0.uuid == targetUUid }),
        let buildPhase = try? target.resourcesBuildPhase()
      else { return }

      let _ = try! buildPhase.add(file: fileReference)
    }

    try xcodeProject.write(path: projectPath)

    guard let finalFile = IosImporter.file(from: fileReference, relativeTo: projectPath, with: nativeTargets, defaultLanguage: .base) else { throw StringzError.importerError("unlocalize", message: "unable to extract old file from file reference") }

    localizable.files.removeAll()
    localizable.files.append(finalFile)
    localizable.status = .unlocalized
    localizable.valueSets = []
  }
}

extension IosImporter {
  private static func readContent(path: Path) -> String {
    var realPath: Path
    do {
      if path.isSymlink {
        realPath = try path.symlinkDestination()
      } else {
        realPath = path
      }
    } catch {
      // ToDo: Send error report to AppCenter
      return ""
    }

    if let content = try? realPath.read(.utf8) { return content }
    if let content = try? realPath.read(.utf16) { return content }

    // ToDo: Send error report to AppCenter
    return ""
  }

  private static func read(path: Path) throws -> Data {
    var realPath: Path

    if path.isSymlink {
      realPath = try path.symlinkDestination()
    } else {
      realPath = path
    }

    return try realPath.read()
  }

  private static func write(content: String, to path: Path) {
    do {
      if path.isSymlink {
        try path.symlinkDestination().write(content)
      } else {
        try path.write(content)
      }
    } catch {
      // ToDo: Send error report to AppCenter
    }
  }
}

enum ExportOrder: Int {
  case sameAsOriginal = 0
  case sameAsBase = 1
  case alphabeticallyAscending = 2
  case alphabeticallyDescending = 3
}

enum CommentStyle: Int {
  case block = 0
  case line = 1
}

enum EmptyLines: Int {
  case always = 0
  case never = 1
  case beforeComments = 2
}

struct ImporterOptions {
  var importAllPlistKeys: Bool = false
  var plistKeys: [PlistKey] = []

  var ignoreEmptyValues: Bool = true
  var ignoreOnlyWhitespaceValues: Bool = false
  var ignoreUnusedValuesInStoryboards: Bool = false
  var ignoreCommentsInStoryboards: Bool = false
  var ignoredValues: [IgnoredValue] = []

  var exportOrder: ExportOrder = .sameAsOriginal
  var commentStyle: CommentStyle = .line
  var emptyLines: EmptyLines = .beforeComments

  var xcodePath: String?
}
