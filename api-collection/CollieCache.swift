//
//  CollieCache.swift
//  api-collection
//
//  Created by Eric on 4/27/16.
//  Copyright © 2016 Simple Guy. All rights reserved.
//

import Foundation

/**
 For all Hashables, the default behavior of `==` is to compare `hashValue`
 */
public func ==<T: Hashable>(lhs: T, rhs: T) -> Bool {
  return lhs.hashValue == rhs.hashValue
}

class CollieCache {
 
  typealias CacheKVP = [String: CachedJSON]
  
  struct CachedJSON {
    let age: NSDate = NSDate()
    let json: Collie.JSON
  }
  
  private static var memCache = [String: CacheKVP]()
  
//  got object response...
//  cache.store('camperVan',      vanObj)
//  objType: String,  obj: NSDictionary
//  
//  got collection response...
//  cache.storeSet('camperVan',     'api.instagram.com/images?s=yellow%20vans', ["1", "3", "42"]
//  objType: String  collectionQuery: String,                   results: [String]
  
  // static func storeCollection(objectType: String, queryKey: String, results: [json]) {}
  // private static func storeCollectionReferences(objectType: String, queryKey: String, references: [String]) {}
  
  
  /**
   Set a value into cache
   TODO: this updates the date at the same time because it creates a whole new cache struct. Should I instead just update the time in certain situations?
   
   - parameter type: The type of the model, eg: Place, User, Dinosaur
   - parameter key:  The key for this instance of the model. Usually an id like 42 or 60DFAA
   - parameter json: A JSON dictionary of values to store
   */
  static func set(type: String, key: String, json: Collie.JSON) {
    memCache[type] = memCache[type] ?? CacheKVP()
    // if get(type, key: key) != nil { print("replacing \(type)[\(key)]") }
    memCache[type]![key] = CachedJSON(json: json)
  }
  
  /**
   Get a value from cache
   
   - parameter type: The type of the model, eg: Place, User, Dinosaur
   - parameter key:  The key for this instance of the model. Usually an id like 42 or 60DFAA
   
   - returns: A response if one can be found
   */
  static func get(type: String, key: String) -> CachedJSON? {
    if let result = memCache[type]?[key] { return result }
    return nil
  }
  
  /**
   Log out everything that's in cache right now
   */
  static func log(){
    print("CollieCache.log()")
    print("--------------------")
    for (type, cache) in memCache {
      print("\(type) (\(cache.count)):")
      for (idx, (_, cachedJSON)) in cache.enumerate() {
        print("[\(String(format: "%03d", idx))] \(-Int(cachedJSON.age.timeIntervalSinceNow))s old. props: \(cachedJSON.json.count)")
      }
    }
    print("--------------------")
  }
  
  
  
}










//
//  APICache.swift
//  api-collection
//
//  Created by Eric on 4/14/16.
//  Copyright © 2016 Simple Guy. All rights reserved.
//





// ------------------------------------------------- Static
//  private static var storage = [ String : APICache ]()
//
//  /**
//   Get a cache object by key
//   - parameter key: Unique string key for this cache (url works)
//   - returns: A cache object you can get data from and inspect for freshness
//   */
//  static func get(key: String) -> APICache {
//    let cache = storage[key] ?? APICache()
//    storage[key] = cache
//    return cache
//  }


  // ------------------------------------------------- Instance
//  private let definitelyOldTheshold:   NSTimeInterval = 60 * 60 * 48   // seconds. if it's older than this, the data can't possibly be any good
//  private let definitelyFreshTheshold: NSTimeInterval = 10             // seconds. If it's younger than this, the data is almost certainly great
//  // if definitelyOld, use greedy invalidation
//  // if definitelyFresh, don't request from server unless `force` is on
//  // In between these old and fresh times, use lazy invalidation strategy
//  
//  private var ageInSeconds: NSTimeInterval { return -lastUpdate.timeIntervalSinceNow }
//  var definitelyOld:   Bool { return ageInSeconds > definitelyOldTheshold   }
//  var definitelyFresh: Bool { return ageInSeconds < definitelyFreshTheshold }
//
//  var freshness: CacheFreshness {
//    print("ageInSeconds: \( lastUpdate.timeIntervalSince1970 == 0 ? "Not Cached" : String(Int(ageInSeconds)) )")
//    if definitelyOld { return .Old }
//    if definitelyFresh { return .Fresh }
//    return .Uncertain
//  }

//  var lastUpdate = NSDate(timeIntervalSince1970: 0)
//  private var _json = [NSDictionary]()
//  var json: [NSDictionary] {
//    get {
//      return self._json
//    }
//    set {
//      self.lastUpdate = NSDate()
//      self._json = newValue
//    }
//  }
