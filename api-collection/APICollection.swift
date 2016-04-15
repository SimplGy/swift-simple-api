//
//  APICollection.swift
//
//  Created by Eric on 3/31/16.
//  Copyright © 2016 Simple Guy. All rights reserved.
//

import Foundation




/// Common behaviors for working with sets of API Models
class APICollection<ModelProtocol where ModelProtocol: APIModel> {
  
  var pendingOperations = 0 // { didSet { print("pendingOperations: \(pendingOperations)") }}
  var thinking: Bool { return pendingOperations > 0 }
  // var afterGet = [] // an array of parser transforms to do after data is gotten. server -> client
  // var beforeSave = [] // an array of things to do to the object before sending it to the server. client -> server
  
  // TODO: arrray of weak subscriber references
  typealias Handler = APIHandler<ModelProtocol>
  var subscribers = Set<Handler>()
  
  /// Timestamped memcache
//  var cache = APICache<ModelProtocol>()
  
  /// The latest server response this collection instance fetched
  /// It's safe to use this directly, but it may be an empty array if the data has never been fetched, or is definitelyOld
//  var latest: [ModelProtocol] { return APICache.latest(self.url) }
//  var latest: [ModelProtocol] { return cache.data }
  var latest = [ModelProtocol]()
//  var latest: [ModelProtocol] {
//    get { return self.cache.definitelyOld ? [] : _latest }
//    set { _latest = newValue }
//  }
  var cache: APICache { return APICache.get(fullUrl) }
  
  let url: String
  private var fullUrl: String { return APIConfig.rootUrl + self.url }
  
  /**
   Create a collection instance
   
   - parameter url: The url to fetch the collection from. Will be appended to APIConfig.rootUrl, if present
   */
  init(url: String) {
    self.url = url
  }
  
  
  
  // ----------------------------- MARK: General API
  
  /**
  Get the most recent value.
  No observation is set up.
  
  - parameter id:    id of the specific object to get. If nil, gets the whole collection
  - parameter force: If true, ignore normal cache rules and assume the local copy is no good. Still does lazy invalidiation though.
  */
  //func get(id: Int? = nil, force: Bool = false) {}
  
  func get(finally: (()->())? = nil) {
    
    print("")
    
    switch cache.freshness {
      
    // The cache is definitely up-to-date, we can just use the memory copy and never ask the server
    // TODO: better design to centralize storage to remove any chance of the instance/memory copy and the cache data getting out of sync
    case .Fresh:
      print(".Fresh")
      got(latest)
      finally?()
      
    // The cache data might be ok. Return the latest data but also query the server for updates
    case .Uncertain:
      print(".Uncertain")
      got(latest)
      getCollection(fullUrl) {
        self.got($0)
        finally?()
      }
      
    // The cache is definitely old. Blank out current results and get new data
    case .Old:
      print(".Old")
      latest = []
      got(latest)
      getCollection(fullUrl) {
        self.got($0)
        finally?()
      }
      
    }
  }
  
  // TODO: move to APIEndpoint or similar facade
  func getCollection(urlString: String, success: ([NSDictionary])->()) {
    
    guard let urlComponents = NSURLComponents(string: urlString) else { return print("Couldn't create url: \(urlString)") }
    urlComponents.queryItems = (urlComponents.queryItems ?? []) + APIConfig.queryParams
    print(urlComponents.queryItems)
    
    guard let url = urlComponents.URL else { return print("Couldn't get NSURL from NSURLComponents: \(urlComponents)") }
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = "GET"
    request.timeoutInterval = APIConfig.timeout
    for (key, val) in APIConfig.headers {
      request.setValue(val, forHTTPHeaderField: key)
    }
    
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
      self.pendingOperations--
      guard let data = data where error == nil else { return print("Networking error: \(error)") }
      guard let httpStatus = response as? NSHTTPURLResponse else { return print("Can't parse NSHTTPURLResponse") }
      guard httpStatus.statusCode == 200 else { return print("statusCode should be 200, but is \(httpStatus.statusCode). Response: \(response)") }
      
      do {
        let json = try self.dictionaryFromData(data)
        self.cache.json = json
        success(json)
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
    get()
  }
  
  /**
   Remove the cache, broadcast an update of this change
   
   - parameter id: if present, invalidate a single id, else invalidate the whole colleciton
   */
  //func invalidate(id: Int?) {}

  
  
  
  
  // ----------------------------- MARK: Private
  private func dictionaryFromData(data: NSData) throws -> [NSDictionary] {
    let anyObj = try NSJSONSerialization.JSONObjectWithData(data, options: []) // let this error bubble up
    if let json = anyObj as? [NSDictionary] {
      return json
    } else if let key = APIConfig.topLevelKey, outer = anyObj as? NSDictionary, json = outer[key] as? [NSDictionary] {
      return json
    }
    throw APIErrors.CantParseDictionaryArray
  }
  
  private func got(response: [NSDictionary]) {
    let parsedItems = response
      .map    { ModelProtocol(json: $0) }
      .filter { $0 != nil }
      .map    { $0! }
    got(parsedItems)
  }
  
  private func got(items: [ModelProtocol]) {
    print("got \(items.count) items")
    
    // if items == self.latest { return print("items are identical") }
    var identical = true
    if items.count != latest.count {
      identical = false
      print("different counts")
    } else {
      for (idx, item) in items.enumerate() {
        if !item.sameValueAs(latest[idx]) {
          identical = false
          print("different values")
          print(item.toJSON())
          print(latest[idx].toJSON())
          break
        }
      }
    }
    
    // Notify subscribers on main thread
    dispatch_async(dispatch_get_main_queue()) {
      //      self.cache.data = parsedItems
      self.latest = items
      if identical { return print("identical items, not broadcasting") }
      self.subscribers.forEach { $0.onUpdate(items: items) }
    }
    
  }
  
  
  
}