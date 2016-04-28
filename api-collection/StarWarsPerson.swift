import Foundation


func ==(lhs: StarWarsPerson, rhs: StarWarsPerson) -> Bool {
  return lhs.hashValue == rhs.hashValue
}

//class StarWarsPerson: CollieModel, CustomStringConvertible {
class StarWarsPerson: CollieModel {
  
  var id:   String = "_"
  var name: String?
  var hairColor: String?
  var eyeColor: String?
  var skinColor: String?
  var height: String?
  var mass: String?
  var gender: String?
  
  var hashValue: Int { return id.hashValue }
  
  
  // MARK: ObjectMapper
  required init?(_ map: Map) {}
  func mapping(map: Map) {
    id        <- map["url"]
    name      <- map["name"]
    hairColor <- map["hair_color"]
    eyeColor  <- map["eye_color"]
    skinColor <- map["skin_color"]
    height    <- map["height"]
    mass      <- map["mass"]
    gender    <- map["gender"]
  }
  
  
  
//  required init?(json: NSDictionary) {
//    guard let id = json["url"] as? String else {
//      print("Failed to init id from json: \(json)")
//      return nil
//    }
//    guard let name = json["name"] as? String else {
//      print("Failed to init name from json: \(json)")
//      return nil
//    }
//    self.id = id
//    self.name = name
//    self.hairColor = json["hair_color"] as? String
//    self.eyeColor = json["eye_color"] as? String
//  }
//  
//  func toJSON() -> NSDictionary {
//    let json = NSMutableDictionary()
//    json.setObject(id, forKey: "url")
//    json.setObject(name, forKey: "name")
//    if let val = hairColor { json.setObject(val, forKey: "hair_color") }
//    if let val = eyeColor  { json.setObject(val, forKey: "eye_color") }
//    return json
//  }
  
}