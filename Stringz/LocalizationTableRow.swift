//
//  LocalizationTableRow.swift
//  Stringz
//
//  Created by Haytham Katby on 12/24/16.
//  Copyright © 2016 Haytham Katby. All rights reserved.
//

import Cocoa

//class LocalizationTableRow: NSTableRowView {
//
//  override func drawSelection(in dirtyRect: NSRect) {
//    if self.selectionHighlightStyle != .none {
//      let selectionRect = NSInsetRect(self.bounds, 0, 0)
//      NSColor(calibratedWhite: 0, alpha: 0.1).setFill()
//      let selectionPath = NSBezierPath(rect: selectionRect)
//      selectionPath.fill()
//
//      let indecatorRect = NSRect(x: 0, y: 0, width: 3, height: self.bounds.height)
//      NSColor(calibratedRed: 7 / 255, green: 76 / 255, blue: 108 / 255, alpha: 1).setFill()
//      let indecatorPath = NSBezierPath(rect: indecatorRect)
//      indecatorPath.fill()
//    }
//  }
//
//  override func draw(_ dirtyRect: NSRect) {
//    super.draw(dirtyRect)
//
//    let indecatorRect = NSRect(x: 0, y: self.bounds.height - 1, width: self.bounds.width, height: 1)
//    NSColor(calibratedWhite: 0.4, alpha: 0.2).setFill()
//    let indecatorPath = NSBezierPath(rect: indecatorRect)
//    indecatorPath.fill()
//  }
//}
