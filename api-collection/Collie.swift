//
//  CollieAPI.swift
//  api-collection
//
//  Created by Eric on 4/14/16.
//  Copyright © 2016 Simple Guy. All rights reserved.
//

import Foundation


/// Base class for your API endpoint and container for configuration
class Collie {
  
  typealias JSON = [String : AnyObject]
  typealias JSONArray = [JSON]
  
  enum Freshness {
    case Old
    case Fresh
    case Uncertain
  }



  // ------------------------------------- MARK: Static

  /// Set `true` if you want to see what Collie is thinking
  static var logTrace = true
  
  /// If it's older than this, the data can't possibly be any good
  static let definitelyOldTheshold:   NSTimeInterval = 60 * 60 * 48 // 48 hours
  
  /// If it's younger than this, the data is almost certainly great, we won't even check the server.
  static let definitelyFreshTheshold: NSTimeInterval = 3
  
  

  // ------------------------------------- MARK: Instance

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
  
  /// What JSON attribute uniquely identifies objects for this API? If it's not "id", you can change the setting here. This is needed to key the cache.
  var idAttribute = "id"

  


  init(_ rootURL: String) {
    self.rootURL = rootURL
  }
  
  func makeCollection<T>(path: String) -> CollieCollection<T> {
    return CollieCollection(path: path, api: self)
  }
  


  // ------------------------------------- MARK: Logging

  static func trace(msg: String, filename: String = #file, line: Int = #line) {
    guard logTrace else { return }
    logInternal("trace", filename: filename, line: line, msg: msg)
  }
  static func warn (msg: String, filename: String = #file, line: Int = #line) {
    logInternal("warn ", filename: filename, line: line, msg: msg)
  }
  private static func logInternal(level: String, filename: String, line: Int, msg: String) {
    let file = CollieParse.cleanFilename(filename)
    print("Collie.\(level) \(file)#\(line): \(msg)")
  }
  
}