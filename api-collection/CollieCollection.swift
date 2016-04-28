//
//  APICollection.swift
//
//  Created by Eric on 3/31/16.
//  Copyright © 2016 Simple Guy. All rights reserved.
//

import Foundation




/// Common behaviors for working with sets of API Models
class CollieCollection<ModelProtocol where ModelProtocol: CollieModel> {
  
  var pendingOperations = 0 // { didSet { print("pendingOperations: \(pendingOperations)") }}
  var thinking: Bool { return pendingOperations > 0 }
  // var afterGet = [] // an array of parser transforms to do after data is gotten. server -> client
  // var beforeSave = [] // an array of things to do to the object before sending it to the server. client -> server
  
  // TODO: arrray of weak subscriber references
  typealias Handler = CollieHandler<ModelProtocol>
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
  
  let api: Collie
  let path: String
  private var fullUrl: String { return api.rootURL + self.path }
  
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
    
    print("")
    
    switch cache.freshness {
      
    // The cache is definitely up-to-date, we can just use the memory copy and never ask the server
    // Behavior: 
    case .Fresh:
      print(".Fresh")
      got(latest)
      finally?()
      
    // The cache data might be ok. Return the latest data but also query the server for updates
    // Behavior: Lazy Invalidation
    case .Uncertain:
      print(".Uncertain")
      got(latest)
      getCollection(fullUrl) {
        self.got($0)
        finally?()
      }
      
    // The cache is definitely old. Blank out current results and get new data
    // Behavior: Greedy Invalidation
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
  func getCollection(urlString: String, success: ([Collie.JSON])->()) {
    
    guard let urlComponents = NSURLComponents(string: urlString) else { return print("Couldn't create url: \(urlString)") }
    urlComponents.queryItems = (urlComponents.queryItems ?? []) + api.queryParams
    guard let url = urlComponents.URL else { return print("Couldn't get NSURL from NSURLComponents: \(urlComponents)") }
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = "GET"
    request.timeoutInterval = api.timeout
    for (key, val) in api.headers {
      request.setValue(val, forHTTPHeaderField: key)
    }
    
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
      self.pendingOperations -= 1
      guard let data = data where error == nil else { return print("Networking error: \(error)") }
      guard let httpStatus = response as? NSHTTPURLResponse else { return print("Can't parse NSHTTPURLResponse") }
      guard httpStatus.statusCode == 200 else { return print("statusCode should be 200, but is \(httpStatus.statusCode). Response: \(response)") }
      
      do {
        let json = try self.jsonFromData(data)
        self.cache.json = json
        success(json)
      } catch {
        print("error converting response to JSONObjectWithData: \(error)")
      }
      
    }
    pendingOperations += 1
    task.resume()
  }
  

  
  // ----------------------------- MARK: Private
  private func jsonFromData(data: NSData) throws -> [Collie.JSON] {
    let anyObj = try NSJSONSerialization.JSONObjectWithData(data, options: []) // let this error bubble up
    if let json = anyObj as? [Collie.JSON] {
      return json
    } else if let key = api.topLevelKey, outer = anyObj as? Collie.JSON, json = outer[key] as? [Collie.JSON] {
      return json
    }
    throw CollieErrors.CantParseNSDataToJsonDictionary
  }
  
  /// Turn a dictionary response into a set of typed objects
  private func got(jsonArray: [Collie.JSON]) {
    let parsedItems = Mapper<ModelProtocol>().mapArray(jsonArray) ?? []
    
    // TODO: figure out design for new 2-layer (mem and disk) cache
    // TODO: safe to assume the order matches?
    for (i, item) in parsedItems.enumerate() {
      CollieCache.set("\(item.dynamicType)", key: String(item.hashValue), json: jsonArray[i])
    }
    CollieCache.log()

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
    //dispatch_async(dispatch_get_main_queue()) {
    Thread.UI {
      self.latest = items
      if identical { return print("identical items, not broadcasting") }
      self.subscribers.forEach { $0.onUpdate(items: items) }
    }
    
  }
  
  
  
}