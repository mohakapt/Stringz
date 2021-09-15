//
//  InfoSearchField.swift
//  Stringz
//
//  Created by Heysem Katibi on 4.01.2021.
//

import Cocoa

class InfoSearchField: NSSearchField {
  private var labelResultCount: NSTextField!

  var infoString: String? {
    get { labelResultCount.stringValue }
    set { labelResultCount.stringValue = newValue ?? ""}
  }
  var infoAttributedString: NSAttributedString? {
    get { labelResultCount.attributedStringValue }
    set { labelResultCount.attributedStringValue = newValue ?? NSAttributedString(string: "") }
  }

  override func awakeFromNib() {
    super.awakeFromNib()

    labelResultCount = NSTextField(wrappingLabelWithString: "")
    labelResultCount.translatesAutoresizingMaskIntoConstraints = false
    labelResultCount.font = NSFont.systemFont(ofSize: 12)
    labelResultCount.textColor = .secondaryLabelColor
    self.addSubview(labelResultCount)

    labelResultCount.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    labelResultCount.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30).isActive = true
  }

  override func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
    return true
  }
}

extension InfoSearchField: NSMenuItemValidation {
  func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
    return true
  }


}
