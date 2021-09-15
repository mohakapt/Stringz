//
//  RegEx.swift
//  Stringz
//
//  Created by Heysem Katibi on 12/22/16.
//  Copyright © 2016 Heysem Katibi. All rights reserved.
//

import Foundation

class RegEx {
  class func matches(for regex: String, in text: String) -> [String] {
    do {
      let regex = try NSRegularExpression(pattern: regex)
      let nsString = text as NSString
      let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
      return results.map { nsString.substring(with: $0.range) }
    } catch let error {
      print("invalid regex: \(error.localizedDescription)")
      return []
    }
  }

  class func replace(_ source: String, with text: String, using regex: String) -> String {
    do {
      let regex = try NSRegularExpression(pattern: regex)
      let nsString = source as NSString
      let results = regex.stringByReplacingMatches(in: source, range: NSRange(location: 0, length: nsString.length), withTemplate: text)
      return results
    } catch let error {
      print("invalid regex: \(error.localizedDescription)")
      return ""
    }
  }
}
