//
//  NSButtonMenuIndicator.swift
//  Stringz
//
//  Created by Haytham Katby on 1/14/17.
//  Copyright © 2017 Haytham Katby. All rights reserved.
//

import Foundation
import Cocoa

class NSMenuIndicatedButton: NSPopUpButton {
  private var isMouseIn = false

  override func awakeFromNib() {
    super.awakeFromNib()

    var trackingOptions = NSTrackingArea.Options()
    trackingOptions.insert(NSTrackingArea.Options.activeInActiveApp)
    trackingOptions.insert(NSTrackingArea.Options.mouseEnteredAndExited)
    trackingOptions.insert(NSTrackingArea.Options.assumeInside)
    trackingOptions.insert(NSTrackingArea.Options.inVisibleRect)

    let focusTrackingArea = NSTrackingArea(rect: NSZeroRect, options: trackingOptions, owner: self, userInfo: nil)
    self.addTrackingArea(focusTrackingArea)
  }

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)

    if isMouseIn && isEnabled {
      NSColor(calibratedWhite: 0.4, alpha: 1).setFill()

      let indecatorPath = NSBezierPath()
      indecatorPath.move(to: NSPoint(x: NSMaxX(dirtyRect) - 14.5, y: NSMaxY(dirtyRect) - 12))
      indecatorPath.relativeLine(to: NSPoint(x: 7, y: 0))
      indecatorPath.relativeLine(to: NSPoint(x: -3.5, y: 3.5))
      indecatorPath.close()

      indecatorPath.fill()
    }
  }

  override func mouseEntered(with event: NSEvent) {
    super.mouseEntered(with: event)

    isMouseIn = true
    self.setNeedsDisplay()
  }

  override func mouseExited(with event: NSEvent) {
    super.mouseExited(with: event)

    isMouseIn = false
    self.setNeedsDisplay()
  }

}
