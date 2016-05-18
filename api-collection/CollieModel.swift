//
//  A definition for the kind of model objects this library can work on
//

import Foundation


/**
 *  This is the base model protocol for objects that API Collie works with
 */
public protocol CollieModel: Unboxable, WrapCustomizable, RawRepresentable, Hashable, CustomStringConvertible {
  
  /// Configure the mapping between client and server property names. keys are client names and values are JSON names eg: "authorId: "author_id"
  static var propertyMapping: [String: String]? { get }
}


/**
 For all CollieModels, the default behavior of `==` is to compare `hashValue`
 */
public func ==<T: CollieModel>(lhs: T, rhs: T) -> Bool {
  return lhs.hashValue == rhs.hashValue
}



extension CollieModel {
  
  /// Default description of a Model
  var description: String { return String(self) } //self.toJSONString(true) ?? "{?}" }
  
  /// Default property mapping is nil (I'd do an optional get-only var protocol requirement but the language doesn't allow it)
  static var propertyMapping: [String:String]? { return nil }
  
  /**
   This is the default implementation of value equality for models.
   If you have a faster way to do value comparison for your model type feel free to override it.
   - parameter otherModel: Another homogenous model to compare to
   - returns: true if every property is the same between both models
   */
  func sameValueAs<T: CollieModel>(otherModel: T) -> Bool {
    do {
      let a: Collie.JSON = try Wrap(self)
      let b: Collie.JSON = try Wrap(otherModel)
      //let same = String(a) == String(b) // Fails on container references (eg: arrays with different memory addresses but the same contents)
      let same = NSDictionary(dictionary: a).isEqualToDictionary(b)
      if !same { Collie.trace("!sameValueAs() \n\(a) \n\(b)") }
      return same
    } catch {
      print("sameValueAs error: \(error)")
      return false
    }
  }
  
  /**
   Check to see if this object is symmetrical--you can turn it into JSON and back, and all the values match
   - returns: true if all the values match
   */
  func isSymmetrical() -> Bool {
    let json = self.rawValue
    guard let other = Self(rawValue: json) else { return false }
    let isSymmetrical = self.sameValueAs(other)
    Collie.trace("[\(json["id"] ?? "")].isSymmetrical()? \(isSymmetrical)")
    return isSymmetrical
  }
  
  // MARK: rawRepresentable
  typealias RawValue = Collie.JSON
  var rawValue: Collie.JSON { return try! Wrap(self) }
  init?(rawValue: Collie.JSON) {
    do {
      self = try Unbox(rawValue)
    } catch {
      print("init?(json:) error: \(error)")
      return nil
    }
  }
  
  static func getKey(key: String) -> String { return Self.propertyMapping?[key] ?? key }
  func keyForWrappingPropertyNamed(propertyName: String) -> String? {
    return Self.getKey(propertyName)
  }
  
  
}