//
//  Sets up a structure to hold common configuration for the application's API interface. Assumes one managed api per app.
//

import Foundation

struct APIConfig {

  /// Default values. Override these or add to them in didFinishLaunchingWithOptions. eg:
  /// APIConfig.rootUrl = "https://api.simple.gy"
  /// APIConfig.timeout = 3.0
  /// APIConfig.headers["Accept"] = "something-else"
  
  
  /// The root of your api. No trailing slash, please.
  static var rootUrl = ""
  
  static var timeout = 5.0
  
  /// KVP of headers to add to every request
  static var headers: [String: String] = [
    "Content-Type": "application/json"
    // "Accept": "application/vnd.waitress.v5+json"
  ]

}