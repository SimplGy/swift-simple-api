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
    let json: CollieAPI.JSON
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
  static func set(type: String, key: String, json: CollieAPI.JSON) {
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
      for (key, cachedJSON) in cache {
        print("[\(key)] \(Int(cachedJSON.age.timeIntervalSinceNow))s old. props: \(cachedJSON.json.count)")
      }
    }
    print("--------------------")
  }
  
  
  
}