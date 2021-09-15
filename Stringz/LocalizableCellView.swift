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
        break;
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

      default: break
      }

      var toolTip = ""
      var iconName: String
      var name = ""
      var count = ""
      var description = ""

      if let parentName = localizable?.parentName, !parentName.isEmpty {
        toolTip += parentName + "/"
        if hasLongName {
          name += toolTip
        }
      }
      if let namez = localizable?.name, !namez.isEmpty {
        if localizable?.localizableType == .config {
          name += namez
        } else {
          name += namez.components(separatedBy: ".").first ?? ""
        }
        toolTip += namez
      }
      self.toolTip = toolTip
      labelName.stringValue = name

      if localizable?.status == .ready || localizable?.status == .saving {
        let total = localizable?.totalCount ?? 0
        let translated = localizable?.translatedCount ?? 0

        var percentage: Double = 0
        if total == 0 {
          percentage = 100
        } else {
          percentage = Double(translated) / Double(total) * 100
        }

        count = "\(translated)/\(total)"
        description = "\(Int(percentage))% completed"
      } else if localizable?.status == .loading {
        description = "Loading..."
      } else if localizable?.status == .unloaded {
        description = "Unloaded"
      }

      switch localizable?.localizableType {
      case .storyboard:
        iconName = "file.storyboard"
        break
      case .xib:
        iconName = "file.xib"
        break
      case .strings:
        iconName = "file.strings"
        break
      case .config:
        iconName = "file.config"
        break
       default:
         iconName = "file.other"
         break
      }

      labelName.textColor = nameColor
      labelCount.isHidden = countHidden
      labelDescription.isHidden = descriptionHidden
      if progressHidden {
        progressIndicator.isHidden = true
        progressIndicator.stopAnimation(progressIndicator)
      } else {
        progressIndicator.isHidden = false
        progressIndicator.startAnimation(progressIndicator)
      }
      self.toolTip = toolTip
      iconImage.image = NSImage(named: iconName)!
      labelName.stringValue = name
      labelCount.stringValue = count
      labelDescription.stringValue = description
    }
  }

}
