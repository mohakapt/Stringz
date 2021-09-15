//
//  ToolbarItem.swift
//  Stringz
//
//  Created by Heysem Katibi on 1.01.2021.
//

import Cocoa

class ValidatableToolbarItem: NSToolbarItem {
  override func validate() {
    if let control = self.view as? NSControl {
      let target: AnyObject
      if let action = self.action,
         let validator = NSApp.target(forAction: action, to: self.target, from: self) as AnyObject? {
        target = validator
      } else if let validator = control.target {
        target = validator
      } else {
        super.validate()
        return
      }

      let result: Bool
      if let target = target as? NSUserInterfaceValidations {
        result = target.validateUserInterfaceItem(self)
      } else {
        result = target.validateToolbarItem(self)
      }

      self.isEnabled = result
      control.isEnabled = result
    }
    
    super.validate()
    return
  }
}

@available(OSX 11.0, *)
class ValidatableSearchToolbarItem: NSSearchToolbarItem {
  override func validate() {
    let target: AnyObject
    if let action = self.action,
       let validator = NSApp.target(forAction: action, to: self.target, from: self) as AnyObject? {
      target = validator
    } else if let validator = searchField.target {
      target = validator
    } else {
      super.validate()
      return
    }

    let result: Bool
    if let target = target as? NSUserInterfaceValidations {
      result = target.validateUserInterfaceItem(self)
    } else {
      result = target.validateToolbarItem(self)
    }

    self.isEnabled = result
    searchField.isEnabled = result
  }
}
