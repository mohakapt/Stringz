//
//  AppDelegate.swift
//  Stringz
//
//  Created by Heysem Katibi on 12/22/16.
//  Copyright © 2016 Heysem Katibi. All rights reserved.
//

import Cocoa
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import PathKit
import Preferences
import Combine
import ValueTransformerKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  @IBOutlet weak var menuItemAddLanguage: NSMenuItem!
  lazy var updaterController = UpdaterController()
  
  private var isOpenPanelRunning = false
  private var isQuitting = false
  private var openProjectCountSubscriber: AnyCancellable?

  private lazy var preferences: [PreferencePane] = [
    GeneralPreferenceViewController(),
    ImportingPreferenceViewController(),
    ExportingPreferenceViewController(),
    StoryboardPreferenceViewController(),
    PlistPreferenceViewController(),
  ]

  private lazy var preferencesWindowController = PreferencesWindowController(
    preferencePanes: preferences,
    style: .toolbarItems,
    animated: true,
    hidesToolbarForSingleItem: true)

  override init() {
    super.init()
    StringTransformers.register()
  }

  func applicationDidFinishLaunching(_ aNotification: Notification) {
//    UserDefaults.clearAll()
    UserDefaults.loadDefaults()

    Language.allCases
      .forEach { language in
        let menuItem = NSMenuItem()
        menuItem.title = language.fiendlyName
        menuItem.identifier = NSUserInterfaceItemIdentifier(rawValue: language.rawValue)
        menuItem.action = Selector(("performAddLanguage:"))
        self.menuItemAddLanguage.submenu?.addItem(menuItem)
      }

    openProjectCountSubscriber = NotificationCenter.default.publisher(for: .OpenProjectCount)
      .receive(on: RunLoop.main)
      .sink { (sender: NotificationCenter.Publisher.Output) in
        guard let openProjectCount = sender.userInfo?["openProjectCount"] as? Int else { return }
        (NSUserDefaultsController.shared.values as? NSObject)?.setValue(openProjectCount > 0, forKey: UserDefaults.KeyHasOpenProjects)
        NSApplication.shared.windows.first(where: { $0.self.className.contains("Preferences") })?.setContentSize(NSSize.zero)
      }

    self.performOpen(self)
    self.windowCountDidChange()

    if Crashes.hasCrashedInLastSession {
      let alert = NSAlert()
      alert.messageText = "Ooops!"
      alert.informativeText = "Looks like the app crashed in the last session. Stringz is still in its early phases and I'm working hard to make it better. If you have the time please consider submitting an issue, This will help to make the app better for you and others."
      alert.addButton(withTitle: "Submit an Issue")
      alert.addButton(withTitle: "Maybe later")

      if alert.runModal() == .alertFirstButtonReturn {
        self.submitIssue(self)
      }
    }
  }

  func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
    return performQuit(sender)
  }

  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    if !flag {
      self.performOpen(self)
      return true
    } else {
      return false
    }
  }

  func application(_ sender: NSApplication, openFile filename: String) -> Bool {
    if let url = URL(string: filename), self.openProject(url){
      return true
    }
    return false
  }

  func windowCountDidChange() {
    let openProjectCount = NSApplication.shared.windows.filter({ $0.windowController is MainWindowController }).count
    UserDefaults.hasOpenProjects = openProjectCount > 0
    NotificationCenter.default.post(name: .OpenProjectCount, object: nil, userInfo: ["openProjectCount": openProjectCount])
  }
}

extension AppDelegate {
  @objc func performOpen(_ sender: Any) {
    if isOpenPanelRunning { return }

    let dialog = NSOpenPanel()

    dialog.canChooseDirectories = false
    dialog.canChooseFiles = true
    dialog.allowsMultipleSelection = false
    dialog.showsResizeIndicator = true
    dialog.title = "Select (xcodeproj) file"
    dialog.allowedFileTypes = ["xcodeproj"]

    isOpenPanelRunning = true
    dialog.begin { result in
      if result == NSApplication.ModalResponse.OK {
        if let url = dialog.url, self.openProject(url) {

        } else {
          let _ = Common.alert(message: "Unable to load your project", informative: "Stringz currently only supports Xcode projects (no support for workspaces), Please select a valid (.xcodeproj) file")
        }
      }

      self.isOpenPanelRunning = false
    }
  }

  func openProject(_ url: URL) -> Bool {
    let currentProject = NSApplication.shared.windows.first { window in
      return (window.windowController as? MainWindowController)?.currentProjectPath == Path(components: url.pathComponents)
    }

    if let currentProject = currentProject {
      currentProject.makeKeyAndOrderFront(self)
    } else {
      let storyboard = NSStoryboard(name: .main, bundle: nil)
      let window = storyboard.instantiateController(withIdentifier: .mainWindow) as! MainWindowController
      window.currentProjectPath = Path(components: url.pathComponents)
      window.window?.title = url.lastPathComponent

      window.showWindow(self)
    }

    NSDocumentController.shared.noteNewRecentDocumentURL(url)
    self.windowCountDidChange()
    return true
  }

  @objc func showPreferences(_ sender: Any) {
    preferencesWindowController.show()
  }

  @objc func visitGithub(_ sender: Any) {
    let url = URL(string: "https://github.com/mohakapt/Stringz")!
    NSWorkspace.shared.open(url)
  }

  @objc func submitIssue(_ sender: Any) {
    let url = URL(string: "https://github.com/mohakapt/Stringz/issues")!
    NSWorkspace.shared.open(url)
  }

  @objc func emailUs(_ sender: Any) {
    let url = URL(string: "mailto:mohakapt@gmail.com")!
    NSWorkspace.shared.open(url)
  }

  @objc func performQuit(_ sender: Any) -> NSApplication.TerminateReply {
    guard let sender = sender as? NSApplication else { return .terminateCancel }
    self.isQuitting = true

    let unsavedWindows = sender.windows.filter { window in
      guard let windowController = window.windowController as? MainWindowController else { return false }
      return windowController.dirtyFilesUUids.count != 0
    }
    if unsavedWindows.count == 0 {
      return .terminateNow
    } else if unsavedWindows.count == 1 {
      self.continueQuitting(didClose: true)
      return .terminateLater
    } else {
      Common.alert(
        message: "You have \(unsavedWindows.count) Stringz projects with unconfirmed changes. Do you want to review these changes before quitting?",
        informative: "If you dont review your projects, all changes will be saved.",
        positiveButton: "Review Changes...",
        negativeButton: "Cancel",
        neutralButton: "Save and Quit") { response in
        switch (response) {
        case NSApplication.ModalResponse.alertFirstButtonReturn:
          self.continueQuitting(didClose: true)
          break

        case NSApplication.ModalResponse.alertThirdButtonReturn:
          unsavedWindows.forEach { ($0.windowController as? MainWindowController)?.saveAll() }
          self.continueQuitting(didClose: true)
          break

        default:
          self.isQuitting = false
          sender.reply(toApplicationShouldTerminate: false)
          break
        }
      }
      return .terminateLater
    }
  }

  func continueQuitting(didClose: Bool) {
    guard isQuitting, didClose else {
      self.isQuitting = false
      NSApplication.shared.reply(toApplicationShouldTerminate: false)
      return
    }

    let unsavedWindows = NSApplication.shared.windows.filter { window in
      guard let windowController = window.windowController as? MainWindowController else { return false }
      return windowController.dirtyFilesUUids.count != 0
    }

    if unsavedWindows.count == 0 {
      NSApplication.shared.reply(toApplicationShouldTerminate: true)
    } else {
      let _ = (unsavedWindows.first?.windowController as? MainWindowController)?.closeDocument()
    }
  }
}
