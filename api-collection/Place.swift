import Foundation


func ==(lhs: Place, rhs: Place) -> Bool {
  return lhs.hashValue == rhs.hashValue
}

class Place: CollieModel, CustomStringConvertible {
  
  // static var cache = APICache<Place>() // requires that I make `Place` a `final` class
  
  var hashValue: Int { return id.hashValue }
//  var hashValue: Int { return id }
  
  var id:   String = "_"
  var name: String = "_" // bugged requirement to init all properties even when returning nil from a failable init. these can be removed in Swift 2.2: http://stackoverflow.com/a/26496022/111243
  var rating: Double?
  var thumbnailUrl: String?
  
  var description: String {
    return "[\(id)] \(name)"
  }
  
  required init?(json: NSDictionary) {

    // If it fits your use case, you can design your client models to accept multiple server JSON formats
    // our id could be in place_id as a string, or in id as an Int
    let googlePlaceId = json["place_id"] as? String
    let waitressId = json["id"] as? Int
    if googlePlaceId == nil && waitressId == nil {
      print("Failed to init id from json: \(json)")
      return nil
    }
    // our name could be in name as a string or as an array of names by language
    guard let name = (json["name"] as? String) ?? (json["name"] as? [String])?[safe: 0] else {
      print("Failed to init name from json: \(json)")
      return nil
    }
    
    self.id = googlePlaceId ?? String(waitressId ?? -1)
    self.name = name
    self.rating = json["rating"] as? Double
    self.thumbnailUrl = json["icon"] as? String
  }
  
  func toJSON() -> NSDictionary {
    let json = NSMutableDictionary()
    json.setObject(id, forKey: "id")
    json.setObject(name, forKey: "name")
    if let rating = rating { json.setObject(rating, forKey: "rating") }
    if let thumbnailUrl = thumbnailUrl { json.setObject(thumbnailUrl, forKey: "icon") }
    return json
  }
  
}