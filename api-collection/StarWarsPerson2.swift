//
//  StarWarsPerson2.swift
//  api-collection
//
//  Created by Eric on 4/27/16.
//  Copyright © 2016 Simple Guy. All rights reserved.
//

import Foundation

class StarWarsPerson2: Mappable, CustomStringConvertible {
  
  var id:   String?
  var name: String?
  var hairColor: String?
  var eyeColor: String?
  
  //var description: String { return "[\(id)] \(name)" }
  var description: String { return self.toJSONString(true) ?? "{..}" }
  
  // MARK ObjectMapper
  required init?(_ map: Map) {}
  func mapping(map: Map) {
    id        <- map["url"]
    name      <- map["name"]
    hairColor <- map["hair_color"]
    eyeColor  <- map["eye_color"]
  }
  
}
