//
//  Debouncer.swift
//  Stringz
//
//  Created by Heysem Katibi on 7.01.2021.
//

import Foundation

typealias Callback = (_ userInfo: Any?) -> Void

class Debouncer: NSObject {
  var callback: Callback
  var delay: Double
  weak var timer: Timer?

  init(delay: Double, callback: @escaping Callback) {
    self.delay = delay
    self.callback = callback
  }

  func call(userInfo: Any? = nil) {
    timer?.invalidate()
    let nextTimer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(Debouncer.fireNow), userInfo: userInfo, repeats: false)
    timer = nextTimer
  }

  func callImmediately(userInfo: Any? = nil) {
    timer?.invalidate()
    timer = nil
    self.callback(userInfo)
  }

  @objc func fireNow(sender: Timer) {
    self.callback(sender.userInfo)
  }
}
