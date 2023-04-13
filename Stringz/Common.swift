//
//  Common.swift
//  Stringz
//
//  Created by Heysem Katibi on 1/4/17.
//  Copyright © 2017 Heysem Katibi. All rights reserved.
//

import Cocoa

class Common {
  private static var textFieldDelegate = EmptyTextFieldDelegate()

  @discardableResult
  static func alert(message: String = "", informative: String = "",
                    positiveButton: String = "OK", negativeButton: String? = nil, neutralButton: String? = nil,
                    window: NSWindow? = nil, completion: ((NSApplication.ModalResponse) -> Void)? = nil) -> NSAlert {

    let alert = NSAlert()
    alert.messageText = message
    alert.informativeText = informative
    alert.addButton(withTitle: positiveButton)

    if let negativeButton = negativeButton {
      alert.addButton(withTitle: negativeButton)
    }

    if let neutralButton = neutralButton {
      alert.addButton(withTitle: neutralButton)
    }

    if let window = window {
      alert.beginSheetModal(for: window, completionHandler: completion)
    } else {
      let result = alert.runModal()
      if let completion = completion {
        completion(result)
      }
    }

    return alert
  }

  static func inputAlert(message: String = "", informative: String = "",
                         inputLabel: String? = nil, placeholder: String? = nil, value: String = "",
                         positiveButton: String = "OK", negativeButton: String? = nil,
                         allowEmpty: Bool = false,
                         window: NSWindow? = nil,
                         completion: ((NSApplication.ModalResponse, String) -> Void)? = nil) -> NSAlert {

    let alert = NSAlert()
    alert.messageText = message
    alert.informativeText = informative
    let button = alert.addButton(withTitle: positiveButton)
    button.isEnabled = !value.isEmpty
    if let negativeButton = negativeButton {
      alert.addButton(withTitle: negativeButton)
    }

    let stackView = NSStackView(frame: NSRect(x: 0, y: 0, width: 290, height: 24))
    stackView.translatesAutoresizingMaskIntoConstraints = true

    if let inputLabel = inputLabel {
      var label: NSTextField

      if #available(OSX 10.12, *) {
        label = NSTextField(labelWithString: inputLabel)
      } else {
        label = NSTextField()
        label.stringValue = inputLabel
      }

      stackView.addArrangedSubview(label)
    }

    let input = NSTextField()
    input.stringValue = value
    input.placeholderString = placeholder

    stackView.addArrangedSubview(input)

    if !allowEmpty {
      textFieldDelegate.button = button
      input.delegate = textFieldDelegate
    }

    alert.accessoryView = stackView

    let alertCompletion: (NSApplication.ModalResponse) -> Void = { result in
      if let completion = completion {
        completion(result, input.stringValue)
      }
    }

    if let window = window {
      alert.beginSheetModal(for: window, completionHandler: alertCompletion)
      input.becomeFirstResponder()
    } else {
      let result = alert.runModal()
      alertCompletion(result)
    }

    return alert
  }

  static func showFeatureNotSupported(window: NSWindow? = nil) {
    let _ = Common.alert(message: "This featrue will be supported very soon.", positiveButton: "OK", window: window)
  }

  class EmptyTextFieldDelegate: NSObject, NSTextFieldDelegate {
    var button: NSButton?

    func controlTextDidChange(_ obj: Notification) {
      if let button = button {
        let textField = obj.object as! NSTextField
        button.isEnabled = !textField.stringValue.isEmpty
      }
    }
  }
}

