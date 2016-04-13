//
//  APICollection.swift
//
//  Created by Eric on 3/31/16.
//  Copyright © 2016 Simple Guy. All rights reserved.
//

import Foundation


public protocol APIModel {
  
  /**
   json -> swift object
   A failable initializer, because we don't trust arbitrary json
   
   - parameter json: Dictionary of values.
   
   - returns: Typed swift model object. If you don't get valid json, return nil
   */
  init?(json: NSDictionary)
  
  /**
   Convert the object into a json representation
   
   - returns: NSDictionary representing the json
   */
  func toJSON() -> NSDictionary
}







/// Common behaviors for working with sets of API Models
class APICollection<ModelType where ModelType: APIModel> {
  
  //typealias gotOneCallback  = (item: T) -> ()
//  typealias onUpdateFn  = (items: [ModelType]) -> ()
//  typealias onErrFn     = (error:  ErrorType ) -> ()
  
  // var afterGet = [] // an array of parser transforms to do after data is gotten. server -> client
  // var beforeSave = [] // an array of things to do to the object before sending it to the server. client -> server
  
  let definitelyOldInHours = 48                 // hours. if it's old than this, the data can't possibly be any good
  let definitelyFreshInSeconds = 120            // seconds. If it's younger than this, the data can't possibly be bad
  var lastUpdate = 0                            // timestamp. How long ago was there a server sync?
    // if definitelyOld, use greedy invalidation
    // if definitelyFresh, don't request from server unless `force` is on
    // In between these old and fresh times, use lazy invalidation strategy
  
  var pendingOperations = 0
  var thinking: Bool { return pendingOperations > 0 }
  
  // TODO: arrray of weak subscriber references
//  var subscribers = [onUpdateFn]()
  typealias Handler = APIHandler<ModelType>
  var subscribers = Set<Handler>()
  
  var latest = [ModelType]()
  
  let apiRoot = "http://asdf.com/" // TODO: put in base API class
//  let url = apiRoot + T.endpoint
  
  
  init() {
  }
  
  
  
  // ----------------------------- MARK: General API
  
  /**
  Get the most recent value.
  No observation is set up.
  
  - parameter id:    id of the specific object to get. If nil, gets the whole collection
  - parameter force: If true, ignore normal cache rules and assume the local copy is no good. Still does lazy invalidiation though.
  */
  //func get(id: Int? = nil, force: Bool = false) {}
  
  func get() {
    // TODO: actually get from server
    let resp = [
      [ "id": 1, "name": "One" ],
      [ "id": 2, "name": "Two" ],
      [ "id": 3, "name": "Three" ]
    ]
    
    self.latest = resp
      .map { ModelType(json: $0) }
      .filter { $0 != nil }
      .map { $0! }
    
    for handler in subscribers {
      handler.onUpdate(items: self.latest)
    }
  }
  
  

  
  
  
  
  /**
  Be notified of future changes, and trigger a request for the most recent value following normal cache rules.
  
  - parameter id: If present, observe a single item, else the whole collection
  */
//  func observe(id: Int? = nil) {}
  
  func observe(handler: Handler) {
    subscribers.insert(handler)
    
    // TODO: update data
    get()
  }
  
  /**
   Remove the cache, broadcast an update of this change
   
   - parameter id: if present, invalidate a single id, else invalidate the whole colleciton
   */
  func invalidate(id: Int?) {}

  
  
  
  
  // ----------------------------- MARK: Private

//  private func addSubscriber(handler: Handler) {
//    
//    for h in subscribers {
//      if h == handler { return }
//    }
//    
//    subscribers.append(handler)
//  }
  
  
  
  
}