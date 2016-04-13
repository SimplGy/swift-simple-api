//
//  APIModel.swift
//  api-collection
//
//  Created by Eric on 4/13/16.
//  Copyright © 2016 Simple Guy. All rights reserved.
//

import Foundation

public protocol APIModel {
  
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
}