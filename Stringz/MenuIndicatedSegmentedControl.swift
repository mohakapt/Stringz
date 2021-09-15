//
//  NSMenuIndicatedSegmentedCell.swift
//  Stringz
//
//  Created by Haytham Katby on 1/15/17.
//  Copyright © 2017 Haytham Katby. All rights reserved.
//

import Foundation
import Cocoa

class NSMenuIndicatedSegmentedControl: NSSegmentedControl {
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
      if selectedSegment == 1 {
        NSColor(calibratedWhite: 0.97, alpha: 1).setFill()
      } else {
        NSColor(calibratedWhite: 0.4, alpha: 1).setFill()
      }

      let indecatorPath = NSBezierPath()
      indecatorPath.move(to: NSPoint(x: NSMaxX(dirtyRect) - 12.5, y: NSMaxY(dirtyRect) - 8.5))
      indecatorPath.line(to: NSPoint(x: NSMaxX(dirtyRect) - 5.5, y: NSMaxY(dirtyRect) - 8.5))
      indecatorPath.line(to: NSPoint(x: NSMaxX(dirtyRect) - 9, y: NSMaxY(dirtyRect) - 5))
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
