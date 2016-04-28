import Foundation


//func ==(lhs: Place, rhs: Place) -> Bool {
//  return lhs.hashValue == rhs.hashValue
//}

class Place: CollieModel, CustomStringConvertible {

  var hashValue: Int { return id.hashValue }
  
  var placeId: String?
  var waitressId: Int64?
  var name: String = "_"
  var rating: Double?
  var thumbnailUrl: String?
  
  var id: String { return placeId ?? waitressId?.description ?? "_" } // Google places puts id in `place_id`; other apis put it elsewhere. Let's make the client model interchangable.
  
  // MARK: ObjectMapper
  required init?(_ map: Map) {}
  func mapping(map: Map) {
    
    // Optional: You can design your client models to accept multiple server JSON formats
    placeId       <- map["place_id"]  // if from google places api
    waitressId    <- (map["id"], TransformOf<Int64, NSNumber>(fromJSON: { $0?.longLongValue }, toJSON: { $0.map { NSNumber(longLong: $0) } })) // if from Waitress api
    name          <- map["name"]      // if from google places api
    if name == "_" {
      name        <- map["name.0"]    // if from waitress api
    }
    rating        <- map["rating"]
    thumbnailUrl  <- map["icon"]
  }
  
}