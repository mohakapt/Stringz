//
//  UpdaterController.swift
//  Stringz
//
//  Created by Maurice Arikoglu on 13.04.23.
//

import Foundation
import Sparkle

class UpdaterController: NSObject {
  
  private lazy var sparkle: SPUStandardUpdaterController = {
    return .init(updaterDelegate: self, userDriverDelegate: self)
  }()
  
  public var automaticallyChecksForUpdates: Bool {
    return sparkle.updater.automaticallyChecksForUpdates
  }
  
  public var automaticallyDownloadsUpdates: Bool {
    return sparkle.updater.automaticallyDownloadsUpdates
  }

  public func setAutomaticallyChecksForUpdates(_ on: Bool) {
    sparkle.updater.automaticallyChecksForUpdates = on
  }
  
  public func setAutomaticallyDownloadsUpdates(_ on: Bool) {
    sparkle.updater.automaticallyDownloadsUpdates = on
  }
  
}

extension UpdaterController: SPUStandardUserDriverDelegate, SPUUpdaterDelegate {
  
  
}
