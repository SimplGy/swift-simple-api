//
//  A definition for the kind of model objects this library can work on
//

import Foundation


/**
 *  This is the base model protocol for objects that API Collie works with
 */
public protocol CollieModel: Mappable, Hashable, CustomStringConvertible {}



extension CollieModel {
  
  /// Default description is just the JSON data
  var description: String { return self.toJSONString(true) ?? "{..}" }
  
  /**
   This is the default implementation of value equality for models.
   It converts to json for comparison. This is expensive, but thorough.
   If you have a faster way feel free to override it.
   - parameter otherModel: Another homogenous model to compare to
   - returns: true if every property is the same between both models
   */
  func sameValueAs<T: CollieModel>(otherModel: T) -> Bool {
    return self.toJSONString() == otherModel.toJSONString()
  }

}