//
//  APICache.swift
//  api-collection
//
//  Created by Eric on 4/14/16.
//  Copyright © 2016 Simple Guy. All rights reserved.
//

import Foundation


enum CacheFreshness {
  case Old
  case Fresh
  case Uncertain
}


public class APICache {
  
  // ------------------------------------------------- Static
  private static var storage = [ String : APICache ]()
  
   /**
   Get a cache object by key
   - parameter key: Unique string key for this cache (url works)
   - returns: A cache object you can get data from and inspect for freshness
   */
  static func get(key: String) -> APICache {
    let cache = storage[key] ?? APICache()
    storage[key] = cache
    return cache
  }
  
  
  
  // ------------------------------------------------- Instance
  private let definitelyOldTheshold:   NSTimeInterval = 60 * 60 * 48   // seconds. if it's older than this, the data can't possibly be any good
  private let definitelyFreshTheshold: NSTimeInterval = 10             // seconds. If it's younger than this, the data is almost certainly great
    // if definitelyOld, use greedy invalidation
    // if definitelyFresh, don't request from server unless `force` is on
    // In between these old and fresh times, use lazy invalidation strategy
  
  private var ageInSeconds: NSTimeInterval { return -lastUpdate.timeIntervalSinceNow }
  var definitelyOld:   Bool { return ageInSeconds > definitelyOldTheshold   }
  var definitelyFresh: Bool { return ageInSeconds < definitelyFreshTheshold }
  
  var freshness: CacheFreshness {
    print("ageInSeconds: \(Int(ageInSeconds))");
    if definitelyOld { return .Old }
    if definitelyFresh { return .Fresh }
    return .Uncertain
  }
  
  var lastUpdate = NSDate(timeIntervalSince1970: 0)
  private var _json = [NSDictionary]()
  var json: [NSDictionary] {
    get {
      return self._json
    }
    set {
      self.lastUpdate = NSDate()
      self._json = newValue
    }
  }
  
}
