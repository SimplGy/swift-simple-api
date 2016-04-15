//
//  CollieAPI.swift
//  api-collection
//
//  Created by Eric on 4/14/16.
//  Copyright © 2016 Simple Guy. All rights reserved.
//

import Foundation


/// Base class for your API endpoint and container for configuration
class CollieAPI {
  
  /// Default values. Override these or add to them in didFinishLaunchingWithOptions. eg:
  /// APIConfig.rootUrl = "https://api.simple.gy"
  /// APIConfig.timeout = 3.0
  /// APIConfig.headers["Accept"] = "anything-you-say-dear"
  /// APIConfig.queryParams.append(NSURLQueryItem(name: "key", value: "YOUR-API-KEY"))
  
  
  
  /// The root of your api endpoint. No trailing slash, please.
  let rootURL: String
  
  /// Request timeout
  var timeout = 5.0
  
  /// KVP of headers to add to every request
  var headers: [String: String] = [ "Content-Type": "application/json" ]
  
  /// KVP of url params to add to every request
  var queryParams = [NSURLQueryItem]()
  
  /// Some apis respond with an object with a key that contains an array of actual results. This string lets you specify that
  var topLevelKey: String?
  
  
  
  
  
  init(_ rootURL: String) {
    self.rootURL = rootURL
  }
  
  func makeCollection<T>(path: String) -> CollieCollection<T> {
    return CollieCollection(path: path, api: self)
  }
  
}