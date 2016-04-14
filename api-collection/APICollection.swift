//
//  APICollection.swift
//
//  Created by Eric on 3/31/16.
//  Copyright © 2016 Simple Guy. All rights reserved.
//

import Foundation


/// Common behaviors for working with sets of API Models
class APICollection<ModelType where ModelType: APIModel> {
  
  let definitelyOldInHours = 48                 // hours. if it's old than this, the data can't possibly be any good
  let definitelyFreshInSeconds = 120            // seconds. If it's younger than this, the data can't possibly be bad
  var lastUpdate = 0                            // timestamp. How long ago was there a server sync?
    // if definitelyOld, use greedy invalidation
    // if definitelyFresh, don't request from server unless `force` is on
    // In between these old and fresh times, use lazy invalidation strategy
  
  var pendingOperations = 0 { didSet { print("pendingOperations: \(pendingOperations)") }}
  var thinking: Bool { return pendingOperations > 0 }
  // var afterGet = [] // an array of parser transforms to do after data is gotten. server -> client
  // var beforeSave = [] // an array of things to do to the object before sending it to the server. client -> server
  
  // TODO: arrray of weak subscriber references
  typealias Handler = APIHandler<ModelType>
  var subscribers = Set<Handler>()
  
  /// Superset of the latest value of each model for all instances of the collection. Duplicates not allowed.
  
  /// The latest value of each model this instance of the collection may care about. Duplicates allowed.
  var latest = [ModelType]()
  
  
  let apiRoot = "http://asdf.com/" // TODO: put in base API class
//  let url = apiRoot + T.endpoint
  
  init() {}
  
  
  
  // ----------------------------- MARK: General API
  
  /**
  Get the most recent value.
  No observation is set up.
  
  - parameter id:    id of the specific object to get. If nil, gets the whole collection
  - parameter force: If true, ignore normal cache rules and assume the local copy is no good. Still does lazy invalidiation though.
  */
  //func get(id: Int? = nil, force: Bool = false) {}
  
  func get() {
    
    let request = NSMutableURLRequest(URL: NSURL(string: "\(APIConfig.rootUrl)/places/nearby?region=8&lat=59.33&lng=18.06&meters=15000000")!)
    request.HTTPMethod = "GET"
    request.timeoutInterval = APIConfig.timeout
    for (key, val) in APIConfig.headers {
      request.setValue(val, forHTTPHeaderField: key)
    }
    
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
      self.pendingOperations--
      // Networking Erors
      guard let data = data where error == nil else { return print("Networking error: \(error)") }
      // HTTP Errors
      guard let httpStatus = response as? NSHTTPURLResponse else { return print("Can't parse NSHTTPURLResponse") }
      guard httpStatus.statusCode == 200 else { return print("statusCode should be 200, but is \(httpStatus.statusCode). Response: \(response)") }
      
      do {
        let json = try self.dictionaryFromData(data)
        self.got(json)
      } catch {
        print("error converting response to JSONObjectWithData: \(error)")
      }
      
    }
    pendingOperations++
    task.resume()
  }
  
  

  
  
  
  
  /**
  Be notified of future changes, and trigger a request for the most recent value following normal cache rules.
  
  - parameter id: If present, observe a single item, else the whole collection
  */
//  func observe(id: Int? = nil) {}
  
  func observe(handler: Handler) {
    subscribers.insert(handler)
    
    //v TODO: update data
    get()
//    APIEndpoint.get("/places/nearby?region=8&lat=59.33&lng=18.06&meters=15000000", got: got)
  }
  
  /**
   Remove the cache, broadcast an update of this change
   
   - parameter id: if present, invalidate a single id, else invalidate the whole colleciton
   */
  func invalidate(id: Int?) {}

  
  
  
  
  // ----------------------------- MARK: Private
  private func dictionaryFromData(data: NSData) throws -> [NSDictionary] {
    let anyObj = try NSJSONSerialization.JSONObjectWithData(data, options: []) // let this error bubble up
    guard let json = anyObj as? [NSDictionary] else { throw APIErrors.CantParseDictionaryArray }
    return json
  }
  
  private func got(response: [NSDictionary]) {
    self.latest = response
      .map { ModelType(json: $0) }
      .filter { $0 != nil }
      .map { $0! }
    
    // Notify subscribers on main thread
    dispatch_async(dispatch_get_main_queue()) {
      self.subscribers.forEach { $0.onUpdate(items: self.latest) }
    }
  }
  
  
  
  
}