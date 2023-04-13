//
//  ImportingPreferenceViewController.swift
//  Stringz
//
//  Created by Heysem Katibi on 14.12.2020.
//

import Cocoa
import Preferences

final class ImportingPreferenceViewController: PreferenceViewController, PreferencePane {
  let preferencePaneIdentifier = Preferences.PaneIdentifier.importing
  let preferencePaneTitle = "Importing"
  lazy var toolbarItemIcon = NSImage(systemSymbolName: "arrow.down.doc", accessibilityDescription: preferencePaneTitle)!
  
  override var nibName: NSNib.Name? { "ImportingPreference" }

  @IBOutlet weak var arrayController: NSArrayController!
  @IBOutlet weak var tableView: NSTableView!
  @IBOutlet weak var segmentedControl: NSSegmentedControl!

  @objc dynamic var ignoredValues: [IgnoredValue]!
  @objc dynamic var sortDescriptors = [
    NSSortDescriptor(key: "name", ascending: true) { ($0 as! String).localizedCaseInsensitiveCompare($1 as! String) },
  ]

  private var shouldAcceptEditing = true

  override func viewDidLoad() {
    super.viewDidLoad()
    self.ignoredValues = UserDefaults.importingIgnoredValues
  }

  private func uuidForRow(_ rowIndex: Int) -> String? {
    return ((tableView.rowView(atRow: rowIndex, makeIfNecessary: true)?.view(atColumn: 0) as? NSTableCellView)?.subviews[1] as? NSTextField)?.stringValue
  }

  @IBAction func segmentedControlClicked(_ sender: Any) {
    guard let segmentedControl = sender as? NSSegmentedControl else { return }
    switch segmentedControl.selectedSegment {
    case 0:
      let newUuid = UUID().uuidString
      self.ignoredValues.append(IgnoredValue(uuid: newUuid, name: ""))

      DispatchQueue.main.async {
        for index in 0..<self.ignoredValues.count {
          if self.uuidForRow(index) == newUuid {
            self.tableView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
            self.tableView.editColumn(0, row: index, with: nil, select: true)
            break
          }
        }
      }
      break

    case 1:
      let uuidsToRemove = tableView.selectedRowIndexes.map { self.uuidForRow($0) }
      self.ignoredValues = ignoredValues.filter { !uuidsToRemove.contains($0.uuid) }
      segmentedControl.setEnabled(false, forSegment: 1)
      UserDefaults.importingIgnoredValues = self.ignoredValues
      break

    default:
      break
    }
  }
}

extension ImportingPreferenceViewController: NSTableViewDelegate, NSTextFieldDelegate {
  func tableViewSelectionDidChange(_ notification: Notification) {
    segmentedControl.setEnabled(tableView.selectedRow != -1, forSegment: 1)
  }

  func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
    // A stupid workarround because this method is being called twice with empty value in the second time
    guard shouldAcceptEditing else {
      self.shouldAcceptEditing = true
      return true
    }
    self.shouldAcceptEditing = false
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) { self.shouldAcceptEditing = true }

    guard tableView.selectedRow != -1,
          let uuid = self.uuidForRow(tableView.selectedRow),
          let ignoredValue = self.ignoredValues.first(where: { $0.uuid == uuid })
    else { return false }

    let identifier = control.identifier?.rawValue
    let newValue = fieldEditor.string

    if identifier == "name" {
      if self.ignoredValues.contains(where: { $0.name == newValue }) { return false }
      ignoredValue.name = newValue
    }

    UserDefaults.importingIgnoredValues = self.ignoredValues
    return true
  }
}

class IgnoredValue: NSObject, NSSecureCoding {
  @objc dynamic var uuid: String
  @objc dynamic var name: String

  static var supportsSecureCoding: Bool {
    return true
  }

  init(uuid: String, name: String) {
    self.uuid = uuid
    self.name = name
  }

  required convenience init(coder: NSCoder) {
    let uuid = coder.decodeObject(forKey: "uuid") as! String
    let name = coder.decodeObject(forKey: "name") as! String

    self.init(uuid: uuid, name: name)
  }

  func encode(with coder: NSCoder) {
    coder.encode(uuid, forKey: "uuid")
    coder.encode(name, forKey: "name")
  }
}
