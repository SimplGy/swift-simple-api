//
//  A definition for the kind of model objects this library can work on
//

import Foundation


 /**
 *  This is the base model protocol for objects that CollieAPI works with
 *  You should be able to init each one from json, and serialize it back to json
 *  TODO: per-object caching means you must also implement Hashable and Equatable so we can find and update cache locations
 */
public protocol CollieModel: Hashable {
  
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


extension CollieModel {

  /**
   This is the default implementation of value equality for models.
   Converting to json for comparison is expensive, but thorough.
   If you have a faster way feel free to override it.
   - parameter otherModel: Another homogenous model to compare to
   - returns: true if every property is the same between both models
   */
  func sameValueAs<T: CollieModel>(otherModel: T) -> Bool {
    return self.toJSON() == otherModel.toJSON()
  }
  
}