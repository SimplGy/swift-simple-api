import Foundation


func ==(lhs: Place, rhs: Place) -> Bool {
  return lhs.hashValue == rhs.hashValue
}

class Place: APIModel, CustomStringConvertible {
  
  // static var cache = APICache<Place>() // requires that I make `Place` a `final` class
  
  var hashValue: Int { return id }
  
  var id: Int = -1
  var name: String = "_" // bugged requirement to init all properties even when returning nil from a failable init. these can be removed in Swift 2.2: http://stackoverflow.com/a/26496022/111243
  
  var description: String {
    return "[\(id)] \(name)"
  }
  
  required init?(json: NSDictionary) {
    guard let id = json["id"] as? Int else {
      print("Failed to init id from json: \(json)")
      return nil
    }
    guard let name = json["name"] as? [String] else {
      print("Failed to init name from json: \(json)")
      return nil
    }
    self.id = id
    self.name = name[0]
  }
  
  func toJSON() -> NSDictionary {
    let json = NSMutableDictionary()
    json.setObject(id, forKey: "id")
    json.setObject([name], forKey: "name")
    return json
  }
  
}