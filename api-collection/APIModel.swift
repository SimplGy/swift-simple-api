//
//  APIModel.swift
//  api-collection
//
//  Created by Eric on 4/13/16.
//  Copyright © 2016 Simple Guy. All rights reserved.
//

import Foundation

public protocol APIModel: Hashable {
  
  // static var cache: APICache<Self> { get }
  
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

  /**
   We use id hashvalue to get equality for determining whether or not to replace an object at a cache key.
   For determining whether broadcasting an update is warranted, though, we need to know if actual values inside the object have changed or not
   
   - parameter otherModel: Another model of the same type, possibly with the same id
   
   - returns: true if the models have all the same values
   */
//  func sameValueAs<T: APIModel>(otherModel: T) -> Bool
  
}


extension APIModel {
  
  func sameValueAs<T: APIModel>(otherModel: T) -> Bool {
    return self.toJSON() == otherModel.toJSON()
  }
  
}