//
//  MainViewController.swift
//  Stringz
//
//  Created by Heysem Katibi on 12/24/16.
//  Copyright © 2016 Heysem Katibi. All rights reserved.
//

import Cocoa

class MainViewController: NSSplitViewController {
  var sidebarViewController: SidebarViewController {
    splitViewItems[0].viewController as! SidebarViewController
  }
  var editorViewController: EditorViewController {
    splitViewItems[1].viewController as! EditorViewController
  }
}
