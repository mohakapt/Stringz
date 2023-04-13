//
//  EditorViewController.swift
//  Stringz
//
//  Created by Heysem Katibi on 12/24/16.
//  Copyright © 2016 Heysem Katibi. All rights reserved.
//

import Cocoa
import Preferences

class EditorViewController: NSViewController {
  @IBOutlet weak var scrollView: NSScrollView!
  @IBOutlet weak var tableView: NSTableView!
  @IBOutlet weak var containerEmpty: NSStackView!
  @IBOutlet weak var labelEmpty: NSTextField!
  @IBOutlet weak var buttonEmpty: NSButton!

  private var windowController: MainWindowController!
  private var localizables: [Localizable] {
    windowController?.localizables ?? []
  }
  private var data: [ValueSet] {
    windowController?.editorManager.data ?? []
  }

  private var isLoadingLocalizable = false
  private var showFlags = UserDefaults.generalShowFlags
  private var showKeyColumn = UserDefaults.showKeyColumn
  private var showCommentColumn = UserDefaults.showCommentColumn


  // MARK: - Overrides
  override func viewDidLoad() {
    super.viewDidLoad()
    self.addObserver(self, forKeyPath: "view.window.windowController", options: .new, context: nil)
  }

  deinit {
    self.removeObserver(self, forKeyPath: "view.window.windowController")
  }

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if let windowController = self.view.window?.windowController as? MainWindowController {
      self.windowController = windowController
    }
  }

  @IBAction func emptyClicked(_ sender: Any) {
    guard let localizable = windowController.selectedLocalizable else { return }

    if localizable.status == .unlocalized {
      windowController.performLocalize(sender)
    } else if localizable.status == .unloaded {
      windowController.loadLocalizables([localizable])
    }
  }


  // MARK: - Helpers
  func sortDescriptor(for columnIdentifier: String) -> NSSortDescriptor {
    let reVal = windowController?.editorManager.sortDescriptors.first(where: { $0.key == columnIdentifier })
    return reVal ?? VSSortDescriptor(key: columnIdentifier, ascending: true)
  }

  func selectLocalizable(at localizableIndex: Int = -1) {
    self.isLoadingLocalizable = true

    var shouldContinue = false
    if localizableIndex == -1 {
      scrollView.isHidden = true
      containerEmpty.isHidden = false
      buttonEmpty.isHidden = true

      labelEmpty.stringValue = "No Selection"
      buttonEmpty.title = ""
      buttonEmpty.image = nil
    } else {
      switch localizables[localizableIndex].status {
      case .ready, .saving:
        scrollView.isHidden = false
        containerEmpty.isHidden = true
        buttonEmpty.isHidden = true

        labelEmpty.stringValue = ""
        buttonEmpty.title = ""
        buttonEmpty.image = nil
        shouldContinue = true
        break
      case .loading:
        scrollView.isHidden = true
        containerEmpty.isHidden = false
        buttonEmpty.isHidden = true

        labelEmpty.stringValue = "Loading..."
        buttonEmpty.title = ""
        buttonEmpty.image = nil
        break
      case .unloaded:
        scrollView.isHidden = true
        containerEmpty.isHidden = false
        buttonEmpty.isHidden = false

        labelEmpty.stringValue = "File is not Loaded"
        buttonEmpty.title = "Load..."
        buttonEmpty.image = NSImage(systemSymbolName: "square.and.arrow.down", accessibilityDescription: "Load File")
        break
      case .unlocalized:
        scrollView.isHidden = true
        containerEmpty.isHidden = false
        buttonEmpty.isHidden = false

        labelEmpty.stringValue = "File is not Localized"
        buttonEmpty.title = "Localize..."
        buttonEmpty.image = NSImage(systemSymbolName: "wand.and.stars", accessibilityDescription: "Localize File")
        break
      }
    }

    tableView.tableColumns.forEach { tableView.removeTableColumn($0) }
    guard shouldContinue else {
      self.isLoadingLocalizable = false
      return
    }

    let languages = localizables[localizableIndex].languages
    let colWidth = (tableView.bounds.width / CGFloat(languages.count + 2)) - 10

    let keyColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "key"))
    keyColumn.width = colWidth
    keyColumn.sortDescriptorPrototype = self.sortDescriptor(for: "key")
    tableView.addTableColumn(keyColumn)

    let commentColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "comment"))
    commentColumn.width = colWidth
    commentColumn.sortDescriptorPrototype = self.sortDescriptor(for: "comment")
    tableView.addTableColumn(commentColumn)

    languages.forEach { lang in
      let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: lang.rawValue))
      column.width = colWidth
      column.sortDescriptorPrototype = self.sortDescriptor(for: lang.rawValue)

      tableView.addTableColumn(column)
    }

    self.updateColumnTitles()
    self.tableView.reloadData()
    self.tableView.sortDescriptors = windowController.editorManager.sortDescriptors

    self.isLoadingLocalizable = false
  }
}

extension EditorViewController: NSTableViewDataSource, NSTableViewDelegate {
  func numberOfRows(in tableView: NSTableView) -> Int {
    return data.count
  }

  func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
    guard !isLoadingLocalizable else { return }
    self.windowController.editorManager.sortDescriptorsDebouncer.call(userInfo: tableView.sortDescriptors)
  }

  func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
    guard data.count > row, let tableColumn = tableColumn, let newValue = object as? String else { return }
    let valueSet = data[row]

    let identifier = tableColumn.identifier.rawValue
    windowController.updateValueSet(valueSet, with: identifier, newValue: newValue)
  }

  func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
    guard data.count > row, let tableColumn = tableColumn else { return nil }
    let valueSet = data[row]

    let identifier = tableColumn.identifier.rawValue
    var value: String?
    var ranges: [NSRange]?
    if identifier == "key" {
      value = valueSet.key
      ranges = valueSet.keyRanges
    } else if identifier == "comment" {
      value = valueSet.comment
      ranges = valueSet.commentRanges
    } else if let language = Language(rawValue: identifier) {
      let val = valueSet.value(for: language)
      value = val?.value
      ranges = val?.valueRanges
    }

    if let value = value, let ranges = ranges {
      let attributated = NSMutableAttributedString(string: value, attributes: [NSAttributedString.Key.underlineStyle: 0])
      for range in ranges {
        if range.location != NSNotFound && range.location + range.length <= (value as NSString).length {
          attributated.addAttribute(.backgroundColor, value: NSColor.systemYellow.withAlphaComponent(0.2), range: range)
          attributated.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
          attributated.addAttribute(.underlineColor, value: NSColor.systemYellow, range: range)
        }
      }
      return attributated
    }

    return nil
  }

  func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
    guard let tableColumn = tableColumn, let localizable = self.windowController.selectedLocalizable else { return false }
    let identifier = tableColumn.identifier.rawValue

    let hasStoryboard = localizable.files.first { $0.type == .storyboard } != nil
    if hasStoryboard && identifier == "key" {
      NSSound.beep()
      return false
    }
    return true
  }

  func tableView(_ tableView: NSTableView, willDisplayCell cell: Any, for tableColumn: NSTableColumn?, row: Int) {
    guard let cell = cell as? NSTextFieldCell, tableColumn?.identifier.rawValue != "comment" else { return }
    cell.drawsBackground = cell.stringValue.isEmpty
    cell.backgroundColor = cell.stringValue.isEmpty ? NSColor.systemRed.withAlphaComponent(0.1) : nil
  }
}

extension EditorViewController {
  override func viewDidAppear() {
    super.viewDidAppear()
    NotificationCenter.default.addObserver(self, selector: #selector(userDefaultsDidChange), name: UserDefaults.didChangeNotification, object: nil)
  }

  override func viewDidDisappear() {
    NotificationCenter.default.removeObserver(self, name: UserDefaults.didChangeNotification, object: nil)
    super.viewDidDisappear()
  }

  func updateColumnTitles() {
    self.tableView.tableColumns.forEach { column in
      let columnIdentifier = column.identifier.rawValue
      if columnIdentifier == "key" {
        column.title = (self.showFlags ? "🔑  " : "") + "Key"
        column.isHidden = !self.showKeyColumn
      } else if columnIdentifier == "comment" {
        column.title = "  " + (self.showFlags ? "✏️  " : "") + "Comment"
        column.isHidden = !self.showCommentColumn
      } else if let lang = Language(rawValue: columnIdentifier) {
        column.title = "  " + (self.showFlags ? lang.flag + "  " : "") + lang.fiendlyName
      }
    }
  }

  @objc func userDefaultsDidChange(_ notification: Notification) {
    if self.showFlags != UserDefaults.generalShowFlags {
      DispatchQueue.main.async {
        self.showFlags = UserDefaults.generalShowFlags
        self.updateColumnTitles()
      }
    }

    if self.showKeyColumn != UserDefaults.showKeyColumn {
      DispatchQueue.main.async {
        self.showKeyColumn = UserDefaults.showKeyColumn
        self.tableView.tableColumns.first(where: { $0.identifier.rawValue == "key" })?.isHidden = !self.showKeyColumn
      }
    }

    if self.showCommentColumn != UserDefaults.showCommentColumn {
      DispatchQueue.main.async {
        self.showCommentColumn = UserDefaults.showCommentColumn
        self.tableView.tableColumns.first(where: { $0.identifier.rawValue == "comment" })?.isHidden = !self.showCommentColumn
      }
    }
  }
}
