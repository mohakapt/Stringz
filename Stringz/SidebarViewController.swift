//
//  SidebarViewController.swift
//  Stringz
//
//  Created by Heysem Katibi on 12/24/16.
//  Copyright © 2016 Heysem Katibi. All rights reserved.
//

import Cocoa

class MyOutlineView: NSOutlineView {
  override func frameOfOutlineCell(atRow row: Int) -> NSRect {
    return NSRect.zero
  }
}

class SidebarViewController: NSViewController {
  @IBOutlet weak var clipView: NSClipView!
  @IBOutlet weak var outlineView: NSOutlineView!

  private var windowController: MainWindowController!
  private var localizables: [Localizable] {
    get {
      return windowController?.localizables ?? []
    }
  }
  private var showUnlocalized = UserDefaults.generalShowUnlocalizedFiles


  // MARK: - Overrides
  override func viewDidLoad() {
    super.viewDidLoad()
    if #available(macOS 11, *) {
      clipView.contentInsets.top = -16
    } else {
      clipView.contentInsets.top = 44
    }

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


  // MARK: - Actions
  @IBAction func newLocalizationClicked(_ sender: Any) {
    Common.showFeatureNotSupported(window: windowController.window)
  }

  @IBAction func renameLocalizationClicked(_ sender: Any) {
    Common.showFeatureNotSupported(window: windowController.window)
  }

  @IBAction func deleteLocalizationClicked(_ sender: Any) {
    Common.showFeatureNotSupported(window: windowController.window)
  }

  // MARK: - Helpers
  func selectLocalizable(at localizableIndex: Int = -1) {
    guard localizableIndex >= 0, localizables.count > localizableIndex else {
      outlineView.deselectAll(outlineView)
      return
    }

    let currentSelectedRow = outlineView.selectedRow
    if let currentSelectedLocalizable = outlineView.item(atRow: currentSelectedRow) as? Localizable,
       let currentSelectedLocalizableIndex = localizables.firstIndex(of: currentSelectedLocalizable),
       currentSelectedLocalizableIndex != localizableIndex {

      let selectedLocalizable = localizables[localizableIndex]
      let newSelectedRow = outlineView.row(forItem: selectedLocalizable)
      let indexSet = IndexSet(integer: newSelectedRow)
      outlineView.selectRowIndexes(indexSet, byExtendingSelection: false)
      outlineView.scrollRowToVisible(newSelectedRow)
    }
  }
}

extension SidebarViewController: NSOutlineViewDataSource, NSOutlineViewDelegate {
  func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
    if let type = item as? LocalizableType {
      return localizables.filter(for: type, includeUnlocalized: showUnlocalized).count
    }

    return localizables.availableTypes(includeUnlocalized: showUnlocalized).count
  }

  func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
    if let type = item as? LocalizableType {
      return localizables.filter(for: type, includeUnlocalized: showUnlocalized).sorted(by:{ $0 < $1 })[index]
    }

    return localizables.availableTypes(includeUnlocalized: showUnlocalized)[index]
  }

  func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
    return item is LocalizableType
  }

  func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
    switch item {
    case is LocalizableType:
      let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "headerCell"), owner: self) as! HeaderCellView
      switch (item as! LocalizableType) {
      case .strings:
        cell.title = "Strings Files"
        break
      case .storyboard:
        cell.title = "Storyboard Files"
        break
      case .xib:
        cell.title = "XIB Files"
        break
      case .config:
        cell.title = "Config Files"
        break
      }

      cell.disclosureClickHandler = {
        if outlineView.isItemExpanded(item) {
          outlineView.animator().collapseItem(item)
        } else {
          outlineView.animator().expandItem(item)
        }
      }
      return cell

    case is Localizable:
      let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "localizableCell"), owner: self) as! LocalizableCellView
      let localizable = item as? Localizable
      cell.hasLongName = localizables.filter({ $0.name == localizable?.name }).count > 1
      cell.localizable = localizable
      return cell

    default:
      return nil
    }
  }

  func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
    return !(item is LocalizableType)
  }

  func outlineViewItemDidCollapse(_ notification: Notification) {
    guard let section = notification.userInfo?["NSObject"] as? LocalizableType else { return }
    let rowIndex = outlineView.row(forItem: section)
    guard let rowView = outlineView.rowView(atRow: rowIndex, makeIfNecessary: false) else {return }
    guard let cell = rowView.view(atColumn: 0) as? HeaderCellView else { return }
    cell.buttonDisclosure.state = .off
  }

  func outlineViewItemDidExpand(_ notification: Notification) {
    guard let section = notification.userInfo?["NSObject"] as? LocalizableType else { return }
    let rowIndex = outlineView.row(forItem: section)
    guard let rowView = outlineView.rowView(atRow: rowIndex, makeIfNecessary: false) else {return }
    guard let cell = rowView.view(atColumn: 0) as? HeaderCellView else { return }
    cell.buttonDisclosure.state = .on
  }

  func outlineViewSelectionDidChange(_ notification: Notification) {
    guard let localizable = outlineView.item(atRow: outlineView.selectedRow) as? Localizable,
          let newIndex = localizables.firstIndex(of: localizable)
    else { return }

    windowController.selectLocalizable(newIndex)
  }
}

extension SidebarViewController {
  override func viewDidAppear() {
    super.viewDidAppear()
    NotificationCenter.default.addObserver(self, selector: #selector(userDefaultsDidChange), name: UserDefaults.didChangeNotification, object: nil)
  }

  override func viewDidDisappear() {
    NotificationCenter.default.removeObserver(self, name: UserDefaults.didChangeNotification, object: nil)
    super.viewDidDisappear()
  }

  @objc func userDefaultsDidChange(_ notification: Notification) {
    guard self.showUnlocalized != UserDefaults.generalShowUnlocalizedFiles else { return }
    self.showUnlocalized = UserDefaults.generalShowUnlocalizedFiles

    DispatchQueue.main.async {
      self.windowController.selectLocalizable(-1)
      self.outlineView.reloadData()
    }
  }
}
