//
//  AppNotifications.swift
//  Stringz
//
//  Created by Heysem Katibi on 4.12.2020.
//

import Foundation

extension Notification.Name {
  static let WatchFile = Self("stringz.notification.WatchFile")
  static let UnwatchFile = Self("stringz.notification.UnwatchFile")

  static func saveFile(uuid: String) -> Notification.Name {
    return Self("stringz.notification.SaveFile.\(uuid)")
  }
  static func reloadFile(uuid: String) -> Notification.Name {
    return Self("stringz.notification.ReloadFile.\(uuid)")
  }

  static let OpenProjectCount = Self("stringz.notification.OpenProjectCount")

  static let SearchQuery = Self("stringz.notification.SearchQuery")
}
