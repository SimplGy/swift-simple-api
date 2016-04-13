import Foundation


class Place: APIModel, CustomStringConvertible {
  
  var id: Int = -1
  var name: String = "_" // bugged requirement to init all properties even when returning nil from a failable init. these can be removed in Swift 2.2: http://stackoverflow.com/a/26496022/111243
  
  var description: String {
    return "[\(id)] \(name)"
  }
  
  required init?(json: NSDictionary) {
    guard let id = json["id"] as? Int, name = json["name"] as? String else {
      return nil
    }
    self.id = id
    self.name = name
  }
  
  func toJSON() -> NSDictionary {
    let json = NSMutableDictionary()
    json.setObject(id, forKey: "id")
    json.setObject(name, forKey: "name")
    return json
  }
  
}