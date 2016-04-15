import Foundation


func ==(lhs: StarWarsPerson, rhs: StarWarsPerson) -> Bool {
  return lhs.hashValue == rhs.hashValue
}

class StarWarsPerson: CollieModel, CustomStringConvertible {
  
  // static var cache = APICache<Place>() // requires that I make `Place` a `final` class
  
  var hashValue: Int { return id.hashValue }
  //  var hashValue: Int { return id }
  
  var id:   String = "_"
  var name: String = "_" // bugged requirement to init all properties even when returning nil from a failable init. these can be removed in Swift 2.2: http://stackoverflow.com/a/26496022/111243
  var hairColor: String?
  var eyeColor: String?
  
  var description: String {
    return "[\(id)] \(name)"
  }
  
  required init?(json: NSDictionary) {
    guard let id = json["url"] as? String else {
      print("Failed to init id from json: \(json)")
      return nil
    }
    guard let name = json["name"] as? String else {
      print("Failed to init name from json: \(json)")
      return nil
    }
    self.id = id
    self.name = name
    self.hairColor = json["hair_color"] as? String
    self.eyeColor = json["eye_color"] as? String
  }
  
  func toJSON() -> NSDictionary {
    let json = NSMutableDictionary()
    json.setObject(id, forKey: "url")
    json.setObject(name, forKey: "name")
    if let val = hairColor { json.setObject(val, forKey: "hair_color") }
    if let val = eyeColor  { json.setObject(val, forKey: "eye_color") }
    return json
  }
  
}