//
// Example implementation of a model
// Demonstrates basic property renaming
//
import Foundation



class StarWarsPerson: CollieModel {
  
  var id:   String
  var name: String
  var hairColor: String
  var eyeColor: String
  var skinColor: String
  var height: String
  var mass: String
  var gender: String
  
  var hashValue: Int { return id.hashValue }
  
  // Configure the renaming from localKey : JsonKey
  static let propertyMapping: [String : String]? = [
    "id": "url",
    "hairColor": "hair_color",
    "eyeColor": "eye_color",
    "skinColor": "skin_color",
  ]
  
  required init(unboxer: Unboxer) {
    
    // Boilerplate... Too bad you can't setValueForKey on a raw swift object :(
    id          = unboxer.unbox( StarWarsPerson.getKey("id") )
    name        = unboxer.unbox( StarWarsPerson.getKey("name") )
    hairColor   = unboxer.unbox( StarWarsPerson.getKey("hairColor") )
    eyeColor    = unboxer.unbox( StarWarsPerson.getKey("eyeColor") )
    skinColor   = unboxer.unbox( StarWarsPerson.getKey("skinColor") )
    height      = unboxer.unbox( StarWarsPerson.getKey("height") )
    mass        = unboxer.unbox( StarWarsPerson.getKey("mass") )
    gender      = unboxer.unbox( StarWarsPerson.getKey("gender") )
    
  }
  
}