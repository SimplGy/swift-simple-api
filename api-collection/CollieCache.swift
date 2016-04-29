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
 
  struct CachedJSON {
    let age = NSDate()
    var secondsOld: Int { return -Int(self.age.timeIntervalSinceNow) }
    let json: Collie.JSON
  }
  typealias CachedJSONKVP = [String:CachedJSON]
  
  struct CachedReferences {
    let age = NSDate()
    var secondsOld: Int { return -Int(self.age.timeIntervalSinceNow) }
    let references: [String]
  }
  typealias CachedReferencesKVP = [String:CachedReferences]
  
  // The memCache is organized by type and key like this: modelMemCache["CamperVan"]["WhiteLightning"]
  private static var collectionMemCache = [String: CachedReferencesKVP ]()
  private static var modelMemCache      = [String: CachedJSONKVP ]()
  
  
  
  /**
   Store a collection of model objects into the cache
   
   - parameter type:        The name of the model type this homogenous collection deals with
   - parameter key:         The key for this collection query, such as "" or ""
   - parameter idAttribute: The location of the unique id property in each model
   - parameter results:     Array of JSON objects to cache
   
   - throws: CollieErrors if it can't find or cast the id inside the JSON
   */
  static func storeCollection(type type: String, key: String, idAttribute: String, results: Collie.JSONArray) throws {
    
    // Store "references" to the ids that this query returns
    let ids = results.flatMap { try? CollieParse.getIdFromJSON($0, idAttribute: idAttribute) }
    collectionMemCache[type] = collectionMemCache[type] ?? CachedReferencesKVP()
    collectionMemCache[type]![key] = CachedReferences(references: ids)
    if ids.count != results.count {
      let missing = results.filter { (try? CollieParse.getIdFromJSON($0, idAttribute: idAttribute)) == nil }
      print("Some \(type) json objects are missing ids in attribute `\(idAttribute)`: \r\n\(missing)")
    }
    
    // Store the individual model objects. This separation allows collections and models to share cache
    let resultsShorted = results[0..<results.count - 3]
    try resultsShorted.forEach { try storeModel(type: type, idAttribute: idAttribute, json: $0) }
    
    log()
    print("")
    print("")
    print("")
    verifyCollectionReferenceIntegrity()
  }
 
  
  
  /**
   Set a value into cache
   TODO: this updates the date at the same time because it creates a whole new cache struct. Should I instead just update the time in certain situations?
   
   - parameter type: The type of the model, eg: Place, User, Dinosaur
   - parameter idAttribute: The property name where the id for this model is found
   - parameter json: A JSON dictionary of values to store
   
   - throws: An exception if the idAttribute isn't found in the object
   */
  static func storeModel(type type: String, idAttribute: String, json: Collie.JSON) throws {
    let key = try CollieParse.getIdFromJSON(json, idAttribute: idAttribute)
    modelMemCache[type] = modelMemCache[type] ?? CachedJSONKVP()
    modelMemCache[type]![key] = CachedJSON(json: json)
  }
  
  
  
  /**
   Get a value from cache
   
   - parameter type: The type of the model, eg: Place, User, Dinosaur
   - parameter key:  The key for this instance of the model. Usually an id like 42 or 60DFAA
   
   - returns: A response if one can be found
   */
  static func getModel(type: String, key: String) -> CachedJSON? {
    return modelMemCache[type]?[key]
  }
  
  
  
  // ---------------------------------------------- MARK: Løgging
  
  /**
   Log out everything that's in cache right now
   */
  static func log(){
    print("")
    print("## Collections:")
    logCollectionsInMemory()
    print("")
    print("## Models:")
    logModelsInMemory()
    print("")
  }
  
  private static func logCollectionsInMemory(fullObjects fullObjects: Bool = false) {
    print("\(collectionMemCache.count) types of CollieCache Collection: (\(collectionMemCache.map({ $0.0 }).joinWithSeparator(", ")))")
    for (type, cacheKVP) in collectionMemCache {
      print("\(cacheKVP.count) \(type) collection query cache entries")
      for (key, cacheEntry) in cacheKVP {
        print("\(key.lockWidth(48)) \(cacheEntry.secondsOld)s old. References: \(cacheEntry.references.count)")
        if fullObjects {
          cacheEntry.references.forEach { print($0) }
        }
      }
    }
  }
  
  private static func logModelsInMemory(detailed detailed: Bool = false) {
    print("\(modelMemCache.count) types of CollieCache Model: (\(modelMemCache.map({ $0.0 }).joinWithSeparator(", ")))")
    for (type, cache) in modelMemCache {
      let totalAge = cache.reduce(Int(0)) { $0 + $1.1.secondsOld }
      let avgAge = totalAge / cache.count
      print("\(cache.count) \(type) model cache entries, averaging \(Int(avgAge))s old")
      if detailed {
        cache.forEach { (key, val) in print("\(key.lockWidth(48)) \(val.secondsOld)s old. props: \(val.json.count)") }
      }
    }
  }
  
  
  
  
  
  /// Because we want to be able to observe old cache items. We can expire old ones and verify it's worked as expected
  //  private static func logCacheObjectsByAge(oldestFirst: Bool = true) {}
  
  /// Because the collection cache just contains ids that reference model cache, we may want to programatically inspect the reference integrity from time to time
  private static func verifyCollectionReferenceIntegrity() {

    for (type, cacheKVP) in collectionMemCache {
      for (collectionQueryKey, cacheEntry) in cacheKVP {
        
        // Get an array of the references that are missing from the model cache (0 would be good)
        let missing = cacheEntry.references.filter { getModel(type, key: $0) == nil }
        
        // Log a message reporting the findings
        let msgPrefix = "\(type.lockWidth(16)) \(collectionQueryKey.lockWidth(48))"
        if missing.count == 0 {
          Collie.trace("\(msgPrefix) found all \(cacheEntry.references.count) references. age: \(cacheEntry.secondsOld)s old.")
        } else {
          Collie.warn("\(msgPrefix) missing \(missing.count) references. age: \(cacheEntry.secondsOld)s old.")
          missing.forEach { Collie.warn("Missing \(type)[\($0)]") }
        }
        
      }
    }
  
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
