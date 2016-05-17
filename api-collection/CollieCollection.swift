//
//  APICollection.swift
//
//  Created by Eric on 3/31/16.
//  Copyright © 2016 Simple Guy. All rights reserved.
//

import Foundation




/// Common behaviors for working with sets of API Models
class CollieCollection<Model where Model: CollieModel> {
  
  var pendingOperations = 0 // { didSet { print("pendingOperations: \(pendingOperations)") }}
  var thinking: Bool { return pendingOperations > 0 }
  // var afterGet = [] // an array of parser transforms to do after data is gotten. server -> client
  // var beforeSave = [] // an array of things to do to the object before sending it to the server. client -> server
  
  // TODO: arrray of weak subscriber references
  typealias Handler = CollieHandler<Model>
  var subscribers = Set<Handler>()
  
  /// The latest server response this collection instance fetched
  /// It's safe to use this directly, but it may be an empty array if the data has never been fetched
  var latest = [Model]()
  
  let api: Collie
  let path: String
  
  /**
   Create a collection instance
   - parameter url: The url to fetch the collection from. Will be appended to APIConfig.rootUrl, if present
   - parameter api: An instance of a CollieAPI, so that we know what endpoint and config to work with
   */
  init(path: String, api: Collie) {
    self.path = path
    self.api = api
  }
  
  
  
  // ----------------------------- MARK: General API
  
  /**
   Watch for future changes, and prompt a check for the latest changes, too.
   - parameter handler: A wrapper around the handler methods you want to implement for the observation
   */
  func observe(handler: Handler) {
    subscribers.insert(handler)
    get()
  }
  
  /**
  Get the most recent value.
  No observation is set up.
  - parameter id:    id of the specific object to get. If nil, gets the whole collection
  - parameter force: If true, ignore normal cache rules and assume the local copy is no good. Still does lazy invalidiation though.
  */
  func get(finally: (()->())? = nil) {
    // TODO: is `String(ModelProtocol.self)` reliable, or do I need a static property on each model?
    api.getCollection(self.path, modelType: String(Model.self), success: self.gotJSON, failure: self.gotError, finally: finally)
  }
  
  
  
  // ----------------------------- MARK: Private
  
  /// Turn a dictionary response into a set of typed objects
  private func gotJSON(jsonArray: Collie.JSONArray) {

    // ## 1. Create typed items from the JSON
    let items = jsonArray.flatMap { Model(json: $0) }
  
    // ## 2. See if the new objects are any different than what we already have. If not, don't broadcast an update
    var identical = true
    
    if items.count != latest.count {
      identical = false
      Collie.trace("\(Model.self) count \(items.count) != \(latest.count)")
    } else {
      for (idx, item) in items.enumerate() {
        if !item.sameValueAs(latest[idx]) {
          identical = false
          Collie.trace("\(Model.self) has different values for at least item \(item)")
          break
        }
      }
    }
    
    // ## 3. Notify subscribers on main thread
    dispatch_async(dispatch_get_main_queue()) {
      self.latest = items
      if identical { return Collie.trace("identical items, not broadcasting") }
      self.subscribers.forEach { $0.onUpdate(items: items) }
    }
    
  }
  
  private func gotError(error: ErrorType) {
    dispatch_async(dispatch_get_main_queue()) {
      self.subscribers.forEach { $0.onErr?(error: error) }
    }
  }
  
  
  
}