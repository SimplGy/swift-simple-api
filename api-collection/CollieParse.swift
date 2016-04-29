//
//  Static data transformation utilities
//  Should be well-tested, you know, eventually.
//

import Foundation


class CollieParse {
  
  
  static func getIdFromJSON(json: Collie.JSON, idAttribute: String) throws -> String {
    guard let val = json[idAttribute] else { throw CollieError.JSONMissingId(json: json, idAttribute: idAttribute) }
    if let str = val as? String {
      return str
    } else if let int64 = (val as? NSNumber)?.longLongValue {
      return String(int64)
    } else if let int = val as? Int {
      return String(int)
    }
    throw CollieError.JSONUnknownTypeId(idValue: "\(val)", idAttribute: idAttribute)
  }
  
  
  /**
   Try to get an array of json dictionaries from the given nsdata
   
   - parameter data:        NSData, usually from an http request
   - parameter topLevelKey: Optional key to look for json data in, eg: "results"
   - throws: CollieErrors.CantParseNSDataToJsonDictionary
   - returns: Array of JSON dictionaries
   */
  static func jsonArrayFromData(data: NSData, topLevelKey key: String? = nil) throws -> Collie.JSONArray {
    let anyObj = try NSJSONSerialization.JSONObjectWithData(data, options: []) // let this error bubble up
    if let key = key, outer = anyObj as? Collie.JSON, json = outer[key] as? [Collie.JSON] {
      return json
    } else if let json = anyObj as? [Collie.JSON] where key == nil {
      return json
    }
    throw CollieError.CantParseNSDataToJsonDictionary
  }
  
//  func jsonFromData(data: NSData) throws -> [Collie.JSON] {
  
  
  
  
}