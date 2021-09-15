//
//  Error.swift
//  Stringz
//
//  Created by Heysem Katibi on 8/1/17.
//
//

import Foundation

enum StringzError: Error {
  case notFoundError
  case importerError(_ domain: String, message: String? = nil)
}
