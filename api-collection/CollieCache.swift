//
//  CollieCache.swift
//
import Foundation



class CollieCache {
 
  typealias CachedJSONKVP = [String:CachedJSON]
  typealias CachedReferencesKVP = [String:CachedReferences]
  
  // The memCache is organized by type and key like this: modelMemCache["CamperVan"]["WhiteLightning"]
  private static var collectionMemCache = [String: CachedReferencesKVP ]()
  private static var modelMemCache      = [String: CachedJSONKVP ]()
  
  
  
  // ------------------------------------------ MARK: Store
  
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
    try results.forEach { try storeModel(type: type, idAttribute: idAttribute, json: $0) }
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
  
  
  
  // ------------------------------------------ MARK: Get
  
  /**
   Get a value from cache, nil if not present or old data
   - parameter type: The type of the model, eg: Place, User, Dinosaur
   - parameter key:  The key for this instance of the model. Usually an id like 42 or 60DFAA
   - returns: A cached JSON object representation
   */
  static func getModel(type type: String, key: String) -> CachedJSON? {
    guard let cache = modelMemCache[type]?[key] else { return nil }
    guard !cache.definitelyOld else {
      Collie.trace("getModel(type: \(type), key: \(key)) is .definitelyOld, invalidating")
      modelMemCache[type]?[key] = nil
      return nil
    }
    return cache
  }
  
  /**
   Get a collection from cache. Returns nil if the cache is old.
   It doesn't
   - parameter type: The type of the model, eg: Place, User, Dinosaur
   - parameter key:  The key for this instance of the model. Usually an id like 42 or 60DFAA
   - returns: A cache object with age metadata and an array of JSON models
   */
  static func getCollection(type type: String, key: String) -> CachedJSONArray? {
    guard let cache = collectionMemCache[type]?[key] else { return nil }
    
    // The whole cache might be old
    guard !cache.definitelyOld else {
      Collie.trace("getCollection(type: \(type), key: \(key)) is .definitelyOld, invalidating")
      collectionMemCache[type]?[key] = nil
      return nil
    }
    
    // The models refered to by this cache might be missing
    let missing = cache.references.filter { getModel(type: type, key: $0) == nil }
    guard missing.count == 0 else {
      Collie.warn("getCollection(type: \(type), key: \(key)) is missing \(missing.count) of the models it has references to, invalidating.")
      collectionMemCache[type]?[key] = nil
      return nil
    }
    
    // TODO: ? Some of the models refered to by this cache might be old
    
    // Simplify the (potential) mismatch in cache age by returning plain model JSON with the age on the whole collection
    let models = cache.references.flatMap({ getModel(type: type, key: $0) }).map { $0.json }
    return CachedJSONArray(age: cache.age, jsonArray: models)
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
        print("\(key.fixedWidth(48)) \(cacheEntry.ageDisplay)s old. References: \(cacheEntry.references.count)")
        if fullObjects {
          cacheEntry.references.forEach { print($0) }
        }
      }
    }
  }
  
  private static func logModelsInMemory(detailed detailed: Bool = false) {
    print("\(modelMemCache.count) types of CollieCache Model: (\(modelMemCache.map({ $0.0 }).joinWithSeparator(", ")))")
    for (type, cache) in modelMemCache {
      let totalAge = cache.reduce(NSTimeInterval(0)) { $0 + $1.1.ageInSeconds }
      let avgAge = Int( totalAge / Double(cache.count) )
      print("\(cache.count) \(type) model cache entries, averaging \(Int(avgAge))s old")
      if detailed {
        cache.forEach { (key, val) in print("\(key.fixedWidth(48)) \(val.ageDisplay)s old. props: \(val.json.count)") }
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
        let missing = cacheEntry.references.filter { getModel(type: type, key: $0) == nil }
        
        // Log a message reporting the findings
        let msgPrefix = "\(type.fixedWidth(16)) \(collectionQueryKey.fixedWidth(48))"
        if missing.count == 0 {
          Collie.trace("\(msgPrefix) found all \(cacheEntry.references.count) references. age: \(cacheEntry.ageDisplay)s old.")
        } else {
          Collie.warn("\(msgPrefix) missing \(missing.count) references. age: \(cacheEntry.ageDisplay)s old.")
          missing.forEach { Collie.warn("Missing \(type)[\($0)]") }
        }
        
      }
    }
  
  }
  
  
  
}



