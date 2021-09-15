//
//  EditorManager.swift
//  Stringz
//
//  Created by Heysem Katibi on 5.01.2021.
//

import Cocoa
import Combine

class EditorManager: NSObject {
  private var delegate: EditorManagerDelegate

  private(set) var sortDescriptors: [NSSortDescriptor]

  private(set) var searchQuery: String
  private(set) var searchType: SearchType
  private(set) var searchScope: SearchScope
  private(set) var searchFields: [SearchField]
  private(set) var searchMode: SearchMode
  private(set) var matchCase: Bool
  private(set) var matchWords: Bool

  private(set) var data: [ValueSet]
  private(set) var matchCount: Int?

  private(set) var sortDescriptorsDebouncer: Debouncer!
  private(set) var searchQueryDebouncer: Debouncer!

  private(set) var isSearchActive = false

  init(delegate: EditorManagerDelegate) {
    self.delegate = delegate

    self.sortDescriptors = [VSSortDescriptor(key: "key", ascending: true)]

    self.searchQuery = ""
    self.searchType = UserDefaults.searchType
    self.searchScope = UserDefaults.searchScope
    self.searchFields = UserDefaults.searchFields
    self.searchMode = UserDefaults.searchMode
    self.matchCase = UserDefaults.searchMatchCase
    self.matchWords = UserDefaults.searchMatchWords

    self.data = []

    super.init()

    self.sortDescriptorsDebouncer = Debouncer(delay: 0.05) { [weak self] (userInfo: Any?) in
      guard let descriptors = userInfo as? [NSSortDescriptor] else { return }
      self?.sortDescriptors = descriptors
      self?.reloadAll()
    }

    self.searchQueryDebouncer = Debouncer(delay: 0.1) { [weak self] (userInfo: Any?) in
      guard let query = userInfo as? String else { return }
      if query.isEmpty {
        self?.searchData(query: "")
      } else if UserDefaults.generalImmediatelySearch {
        self?.searchData(query: query)
        self?.selectSearchResult(which: .current)
      } else {
        self?.searchQuery = query
        self?.pauseSearch()
      }
    }

    NotificationCenter.default.addObserver(self, selector: #selector(userDefaultsDidChange), name: UserDefaults.didChangeNotification, object: nil)
  }

  @objc private func userDefaultsDidChange(_ notification: Notification) {
    DispatchQueue.main.async {
      if self.searchType != UserDefaults.searchType {
        self.searchType = UserDefaults.searchType
        self.reloadAll()
        self.searchData()
      }

      if self.searchScope != UserDefaults.searchScope {
        self.searchScope = UserDefaults.searchScope
        self.searchData()
      }

      if self.searchFields != UserDefaults.searchFields {
        self.searchFields = UserDefaults.searchFields
        self.searchData()
      }

      if self.searchMode != UserDefaults.searchMode {
        self.searchMode = UserDefaults.searchMode
        self.searchData()
      }

      if self.matchCase != UserDefaults.searchMatchCase {
        self.matchCase = !self.matchCase
        self.searchData()
      }

      if self.matchWords != UserDefaults.searchMatchWords {
        self.matchWords = !self.matchWords
        self.searchData()
      }
    }
  }

  func selectLocalizable(at localizableIndex: Int = -1) {
    let expression = ".*stringz.*editor.*select.*valuesets.*reloadifnecessary.*scrolltoselection.*"
    let calledBySelector = Thread.callStackSymbols.contains(where: { !($0.range(of: expression, options: [.regularExpression, .caseInsensitive])?.isEmpty ?? true) })

    if UserDefaults.generalAlwaysClearSearch {
      if !calledBySelector && !searchQuery.isEmpty {
        self.searchQueryDebouncer.callImmediately(userInfo: "")
      }
    } else {
      if UserDefaults.generalImmediatelySearch {
        if searchScope == .current {
          self.searchData()
        }
      } else {
        if !calledBySelector {
          self.pauseSearch()
        }
      }
    }

    guard localizableIndex >= 0, delegate.localizables.count > localizableIndex else {
      self.data = []
      return
    }

    let localizable = delegate.localizables[localizableIndex]
    self.data = localizable.search(for: searchType, sortDescriptors: sortDescriptors)
  }
}

extension EditorManager: Cancellable {
  func cancel() {
    NotificationCenter.default.removeObserver(self, name: UserDefaults.didChangeNotification, object: nil)
  }
}


// MARK: - TableView Manager
extension EditorManager {
  private func reloadAll() {
    if let selectedLocalizable = delegate.selectedLocalizable {
      self.data = selectedLocalizable.search(for: searchType, sortDescriptors: sortDescriptors)
    } else {
      self.data = []
    }

    if let tableView = delegate.tableView {
      tableView.reloadData()
    }
  }

  func reloadChanges(in localizableIndex: Int? = nil, including: [ValueSet] = []) {
    let localizableIndex = localizableIndex ?? delegate.selectedLocalizableIndex
    guard localizableIndex >= 0,
          delegate.localizables.count > localizableIndex,
          let tableView = delegate.tableView
    else { return }

    if delegate.selectedLocalizableIndex != localizableIndex {
      delegate.selectLocalizable(localizableIndex, reload: false)
      return
    }

    let localizable = delegate.localizables[localizableIndex]
    let newData = localizable.search(for: searchType, sortDescriptors: sortDescriptors)
    var diff = newData.difference(from: self.data)

    let bigData = (delegate.selectedLocalizable?.totalCount ?? 0) > 1000
    if !bigData { diff = diff.inferringMoves() }

    if diff.count == 0 && including.count == 0 { return }

    var removedSet = IndexSet()
    var insertedSet = IndexSet()
    var movedSet = [(from: Int, to: Int)]()
    var reloadedSet = IndexSet()

    for change in diff {
      switch change {
      case .remove(let offset, _, let move):
        if let move = move {
          movedSet.append((offset, move))
        } else {
          removedSet.insert(offset)
        }

      case .insert(let offset, _, let move):
        if move == nil {
          insertedSet.insert(offset)
        }
      }
    }
    for valueSet in including {
      if let index = newData.firstIndex(of: valueSet) {
        reloadedSet.insert(index)
      }
    }

    tableView.beginUpdates()
    self.data = newData

    if !removedSet.isEmpty {
      tableView.removeRows(at: removedSet, withAnimation: .effectFade)
    }

    if !insertedSet.isEmpty {
      tableView.insertRows(at: insertedSet, withAnimation: .effectFade)
    }

    if !movedSet.isEmpty {
      for move in movedSet {
        tableView.animator().moveRow(at: move.from, to: move.to)
      }
    }

    if !reloadedSet.isEmpty {
      let columnIndexSet = IndexSet(0..<tableView.numberOfColumns)
      tableView.reloadData(forRowIndexes: reloadedSet, columnIndexes: columnIndexSet)
    }

    tableView.endUpdates()

    if UserDefaults.generalImmediatelySearch {
      self.searchData()
    } else {
      self.pauseSearch()
    }
  }

  func select(valueSets: [ValueSet], in localizableIndex: Int? = nil, reloadIfNecessary: Bool = false, scrollToSelection: Bool = true) {
    let localizableIndex = localizableIndex ?? delegate.selectedLocalizableIndex
    guard localizableIndex >= 0,
          delegate.localizables.count > localizableIndex,
          let tableView = delegate.tableView
    else { return }

    if delegate.selectedLocalizableIndex != localizableIndex {
      delegate.selectLocalizable(localizableIndex, reload: false)
      self.select(valueSets: valueSets, in: localizableIndex, reloadIfNecessary: reloadIfNecessary)
      return
    }

    var shouldReload = false
    var indexSet = IndexSet()

    for valueSet in valueSets {
      if let index = self.data.firstIndex(of: valueSet) {
        indexSet.insert(index)
      } else {
        shouldReload = true
        if reloadIfNecessary { break }
      }
    }

    if shouldReload && reloadIfNecessary {
      self.searchQueryDebouncer.callImmediately(userInfo: "")
      self.searchType = .all
      self.reloadAll()

      DispatchQueue.main.async {
        self.select(valueSets: valueSets, in: localizableIndex)
      }
    } else {
      tableView.selectRowIndexes(indexSet, byExtendingSelection: false)
      if !indexSet.isEmpty {
        tableView.scrollRowToVisible(indexSet.first!)
      }
    }
  }
}


// MARK: - Search Manager
extension EditorManager {
  private func searchExpression(query: String) throws -> String {
    let escapedQuery = NSRegularExpression.escapedPattern(for: searchQuery)
    let expression: String

    switch searchMode {
    case .contains:
      expression = matchWords ? "\\b\(escapedQuery)\\b" : escapedQuery
    case .startsWith:
      expression = matchWords ? "^\(escapedQuery)\\b" : "^\(escapedQuery)"
    case .endsWith:
      expression = matchWords ? "\\b\(escapedQuery)$" : "\(escapedQuery)$"

    case .regularExpression:
      let _ = try NSRegularExpression(pattern: searchQuery)
      expression = searchQuery
    }

    return expression
  }

  private func pauseSearch() {
    guard let tableView = delegate.tableView, let searchField = delegate.searchField else { return }

    delegate.localizables.forEach { localizable in
      localizable.valueSets.forEach { valueSet in
        valueSet.keyRanges.removeAll()
        valueSet.commentRanges.removeAll()
        valueSet.values.forEach { value in
          value.valueRanges.removeAll()
        }
      }
    }

    self.isSearchActive = false
    tableView.reloadData()
    searchField.infoString = nil
  }

  private func searchData(query: String? = nil) {
    guard query != nil || !searchQuery.isEmpty else { return }
    guard let tableView = delegate.tableView, let searchField = delegate.searchField else { return }

    delegate.localizables.forEach { localizable in
      localizable.valueSets.forEach { valueSet in
        valueSet.keyRanges.removeAll()
        valueSet.commentRanges.removeAll()
        valueSet.values.forEach { value in
          value.valueRanges.removeAll()
        }
      }
    }

    if let query = query { searchQuery = query }

    if searchQuery.isEmpty {
      tableView.reloadData()
      searchField.stringValue = ""
      searchField.infoString = nil
      self.isSearchActive = false
      return
    }

    do {
      let _ = try self.searchExpression(query: searchQuery)
    } catch {
      tableView.reloadData()
      searchField.infoAttributedString = NSMutableAttributedString(string: "Invalid RegEx", attributes: [NSAttributedString.Key.foregroundColor: NSColor.systemRed.withAlphaComponent(0.8)])
      self.isSearchActive = false
      return
    }

    var scope = [Localizable]()
    if searchScope == .all {
      scope.append(contentsOf: delegate.localizables)
    } else if delegate.hasSelectedLocalizable {
      scope.append(delegate.selectedLocalizable!)
    }

    var matchCount = 0
    for localizable in scope {
      let valueSets = localizable.valueSets(by: searchType)
      matchCount += self.validateSearch(for: valueSets)
    }

    tableView.reloadData()
    searchField.infoString = String(matchCount) + " " + (matchCount == 1 ? "match" : "matches")
    self.isSearchActive = true
  }

  private func validateSearch(for valueSets: [ValueSet]) -> Int {
    let checkKey = searchFields.contains(.key)
    let checkComment = searchFields.contains(.comment)
    let checkValues = searchFields.contains(.values)

    let expression: String
    do {
      expression = try self.searchExpression(query: searchQuery)
    } catch {
      return 0
    }

    var compareOptions = String.CompareOptions.regularExpression
    if !matchCase && searchMode != .regularExpression {
      compareOptions.insert(.caseInsensitive)
    }

    var matchCount = 0
    for valueSet in valueSets {
      var hasMatch = false

      if checkKey {
        let ranges = valueSet.key
          .ranges(of: expression, options: compareOptions)
          .map { NSRange($0, in: valueSet.key) }

        valueSet.keyRanges.append(contentsOf: ranges)
        hasMatch = hasMatch || ranges.count > 0
      }

      if checkComment {
        let ranges = valueSet.comment
          .ranges(of: expression, options: compareOptions)
          .map { NSRange($0, in: valueSet.comment) }

        valueSet.commentRanges.append(contentsOf: ranges)
        hasMatch = hasMatch || ranges.count > 0
      }

      if checkValues {
        for value in valueSet.values {
          let ranges = value.value
            .ranges(of: expression, options: compareOptions)
            .map { NSRange($0, in: value.value) }

          value.valueRanges.append(contentsOf: ranges)
          hasMatch = hasMatch || ranges.count > 0
        }
      }

      if hasMatch { matchCount += 1 }
    }

    return matchCount
  }

  func selectSearchResult(which: SelectSearchResult) {
    guard let tableView = delegate.tableView else { return }

    if !self.isSearchActive {
      self.searchData(query: searchQuery)
    }

    let localizables: [Localizable]
    if searchScope == .all {
      localizables = LocalizableType.allCases
        .map { delegate.localizables.filter(for: $0).sorted(by:{ $0 < $1 }) }
        .flatMap { $0 }
    } else {
      if let selectedLocalizable = delegate.selectedLocalizable {
        localizables = [selectedLocalizable]
      } else {
        return
      }
    }

    let anchorLocalizable = delegate.selectedLocalizableIndex < 0 ? localizables[0] : delegate.selectedLocalizable!
    let anchorLocalizableIndex = localizables.firstIndex(of: anchorLocalizable)!
    let anchorRowIndex = tableView.selectedRowIndexes.first ?? 0

    var anchor = 0
    for index in 0..<anchorLocalizableIndex {
      anchor += localizables[index].valueSets(by: searchType).count
    }
    anchor += anchorRowIndex
    if which == .next { anchor += 1 }
    if which == .previous { anchor += -1 }

    let valueSets = localizables.flatMap { $0.search(for: searchType, sortDescriptors: sortDescriptors) }

    for var index in 0..<valueSets.count {
      if which == .previous {
        index = (valueSets.count + (anchor - index)) % valueSets.count
      } else {
        index = (index + anchor) % valueSets.count
      }

      let valueSet = valueSets[index]
      let hasMatch = !valueSet.keyRanges.isEmpty || !valueSet.commentRanges.isEmpty || valueSet.values.contains(where: { !$0.valueRanges.isEmpty })

      if hasMatch, let localizableIndex = delegate.localizables.firstIndex(where: { $0.valueSets.contains(valueSet ) }) {
        self.select(valueSets: [valueSet], in: localizableIndex, reloadIfNecessary: true, scrollToSelection: true)
        return
      }
    }
  }
}


// MARK: - Editor Manager Delegate
protocol EditorManagerDelegate {
  var localizables: [Localizable] { get }
  var selectedLocalizableIndex: Int { get }

  var tableView: NSTableView? { get }
  var searchField: InfoSearchField! { get }

  var hasSelectedLocalizable: Bool { get }
  var selectedLocalizable: Localizable? { get }

  func selectLocalizable(_ localizableIndex: Int, reload: Bool)
}

extension EditorManagerDelegate {
  var hasSelectedLocalizable: Bool {
    return selectedLocalizableIndex >= 0
  }

  var selectedLocalizable: Localizable? {
    guard selectedLocalizableIndex >= 0, localizables.count > selectedLocalizableIndex else { return nil }
    return localizables[selectedLocalizableIndex]
  }
}

extension ValueSet {
  var keyRanges: [NSRange] {
    get {
      if let ranges = extras["keyRange"] as? [NSRange] {
        return ranges
      } else {
        let array = [NSRange]()
        extras["keyRange"] = array
        return array
      }
    }
    set { extras["keyRange"] = newValue }
  }

  var commentRanges: [NSRange] {
    get {
      if let ranges = extras["commentRange"] as? [NSRange] {
        return ranges
      } else {
        let array = [NSRange]()
        extras["commentRange"] = array
        return array
      }
    }
    set { extras["commentRange"] = newValue }
  }
}

extension Value {
  var valueRanges: [NSRange] {
    get {
      if let ranges = extras["valueRange"] as? [NSRange] {
        return ranges
      } else {
        let array = [NSRange]()
        extras["valueRange"] = array
        return array
      }
    }
    set { extras["valueRange"] = newValue }
  }
}

fileprivate extension Localizable {
  func valueSets(by type: SearchType) -> [ValueSet] {
    switch type {
    case .all: return valueSets
    case .untranslated: return untranslated
    case .translated: return translated
    }
  }
}

enum SelectSearchResult {
  case current
  case next
  case previous
}
