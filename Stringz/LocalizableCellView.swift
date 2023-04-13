//
//  LocalizableCellView.swift
//  Stringz
//
//  Created by Heysem Katibi on 12/24/16.
//  Copyright © 2016 Heysem Katibi. All rights reserved.
//

import Cocoa

class LocalizableCellView: NSTableCellView {
  @IBOutlet weak var iconImage: NSImageView!
  @IBOutlet weak var labelName: NSTextField!
  @IBOutlet weak var labelCount: NSTextField!
  @IBOutlet weak var labelDescription: NSTextField!
  @IBOutlet weak var progressIndicator: NSProgressIndicator!

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  var hasLongName = false

  var localizable: Localizable? {
    didSet {
      var nameColor = NSColor.labelColor
      var countHidden = true
      var descriptionHidden = false
      var progressHidden = true

      switch localizable?.status {
      case .ready, .saving:
        countHidden = false
        break
        
      case .loading:
        nameColor = .secondaryLabelColor
        progressHidden = false
        break
        
      case .unloaded:
        nameColor = .tertiaryLabelColor
        break
        
      case .unlocalized:
        nameColor = .tertiaryLabelColor
        descriptionHidden = true
        break

      default:
        break
        
      }

      var toolTip = ""
      var name = ""
      var count = ""
      var description = ""

      if let parentName = localizable?.parentName,
          !parentName.isEmpty {
        
        toolTip += parentName + "/"
        
        if hasLongName {
          name += toolTip
        }
      }
      
      if let namez = localizable?.name,
         !namez.isEmpty {
        
        if localizable?.localizableType == .config {
          name += namez
        } else {
          name += namez.components(separatedBy: ".").first ?? ""
        }
        
        toolTip += namez
      }
      
      if localizable?.status == .ready || localizable?.status == .saving {
        let total = localizable?.totalCount ?? 0
        let translated = localizable?.translatedCount ?? 0

        let percentage: Double = total == 0 ? 100 : Double(translated) / Double(total) * 100

        count = "\(translated)/\(total)"
        description = "\(Int(percentage))% completed"
      } else if localizable?.status == .loading {
        description = "Loading..."
      } else if localizable?.status == .unloaded {
        description = "Unloaded"
      }

      if progressHidden {
        progressIndicator.isHidden = true
        progressIndicator.stopAnimation(progressIndicator)
      } else {
        progressIndicator.isHidden = false
        progressIndicator.startAnimation(progressIndicator)
      }
      
      labelName.textColor = nameColor
      labelCount.isHidden = countHidden
      labelDescription.isHidden = descriptionHidden
      labelName.stringValue = name
      labelCount.stringValue = count
      labelDescription.stringValue = description
      self.toolTip = toolTip
      
      switch localizable?.localizableType {
      case .storyboard:
        iconImage.image = NSImage(systemSymbolName: "doc.richtext", accessibilityDescription: localizable?.name)!
        break
      case .xib:
        iconImage.image = NSImage(systemSymbolName: "doc.text.image", accessibilityDescription: localizable?.name)!
        break
      case .strings:
        iconImage.image = NSImage(systemSymbolName: "doc.append", accessibilityDescription: localizable?.name)!
        break
      case .config:
        iconImage.image = NSImage(systemSymbolName: "doc.badge.gearshape", accessibilityDescription: localizable?.name)!
        break
       default:
        iconImage.image = NSImage(systemSymbolName: "doc", accessibilityDescription: localizable?.name)!
         break
      }
    }
  }

}
