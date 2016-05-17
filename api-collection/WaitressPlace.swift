//
//  GooglePlace.swift
//  api-collection
//
//  Created by Eric on 5/17/16.
//  Copyright © 2016 Simple Guy. All rights reserved.
//
import Foundation



class WaitressPlace: Place {
  
  var hashValue: Int { return id.hashValue }
  
  let waitressId: Int
  let waitressNames: [String]
  let city: String
  
  var id: String { return waitressId.description }
  var name: String { return waitressNames[0] }
  
  static let propertyMapping: [String : String]? = [
    "waitressId": "id",
    "waitressNames": "name"
  ]
  
  required init(unboxer: Unboxer) {
    waitressId    = unboxer.unbox( WaitressPlace.getKey("waitressId") )
    waitressNames = unboxer.unbox( WaitressPlace.getKey("waitressNames") )
    city          = unboxer.unbox( WaitressPlace.getKey("city") )
  }
  
  
  
}