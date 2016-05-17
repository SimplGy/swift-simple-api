//
//  GooglePlace.swift
//  api-collection
//
//  Created by Eric on 5/17/16.
//  Copyright © 2016 Simple Guy. All rights reserved.
//
import Foundation



class GooglePlace: Place {
  
  var hashValue: Int { return id.hashValue }
  
  let id: String
  let name: String
  let rating: Double
  let thumbnailUrl: String
  
  static let propertyMapping: [String : String]? = [
    "id": "place_id",
    "thumbnailUrl": "icon",
  ]
  
  required init(unboxer: Unboxer) {
    id            = unboxer.unbox( GooglePlace.getKey("id") )
    name          = unboxer.unbox( GooglePlace.getKey("name") )
    rating        = unboxer.unbox( GooglePlace.getKey("rating") )
    thumbnailUrl  = unboxer.unbox( GooglePlace.getKey("thumbnailUrl") )
  }
  
}