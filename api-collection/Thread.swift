//
//  Thread.swift
//  api-collection
//
//  Created by Eric on 4/27/16.
//  Copyright © 2016 Simple Guy. All rights reserved.
//

import Foundation


class Thread {

  /// Call a given function on the UI thread
  static func UI(block: ()->()) {
    dispatch_async(dispatch_get_main_queue(), block)
  }

}