//
//  HeaderCellView.swift
//  Stringz
//
//  Created by Heysem Katibi on 5.12.2020.
//

import Cocoa

class HeaderCellView: NSTableCellView {
  @IBOutlet weak var labelTitle: NSTextField!
  @IBOutlet weak var buttonDisclosure: NSButton!
  @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
  var disclosureClickHandler: (() -> Void)?

  private var trackingArea: NSTrackingArea?

  override func awakeFromNib() {
    super.awakeFromNib()
    buttonDisclosure.alphaValue = 0
    
    if #available(macOS 11, *) {
      trailingConstraint.constant = 0
    } else {
      trailingConstraint.constant = 8
    }
  }

  var title: String? {
    didSet {
      labelTitle.stringValue = title ?? ""
    }
  }

  var isExpanded: Bool = false {
    didSet {
      buttonDisclosure.state = isExpanded ? .on : .off
    }
  }

  @IBAction func disclosureClicked(_ sender: Any) {
    disclosureClickHandler?()
  }

  override func updateTrackingAreas() {
    super.updateTrackingAreas()

    if let trackingArea = self.trackingArea {
      self.removeTrackingArea(trackingArea)
    }

    let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeAlways]
    let trackingArea = NSTrackingArea(rect: self.bounds, options: options, owner: self, userInfo: nil)
    self.addTrackingArea(trackingArea)
  }

  override func mouseEntered(with event: NSEvent) {
    buttonDisclosure.alphaValue = 1
  }

  override func mouseExited(with event: NSEvent) {
    buttonDisclosure.alphaValue = 0
  }
}
