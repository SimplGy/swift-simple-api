import Foundation



protocol CachedThing: CustomStringConvertible {
  var age: NSDate { get }
}

struct CachedJSON: CachedThing {
  let age = NSDate()
  let json: Collie.JSON
}

struct CachedReferences: CachedThing {
  let age = NSDate()
  let references: [String]
}

struct CachedJSONArray: CachedThing {
  let age: NSDate // this age is copied from the cached references' age
  let jsonArray: Collie.JSONArray
}



extension CachedThing {
  
  var description: String { return "\(self.dynamicType) \(ageDisplay)s old." }
  
  var ageInSeconds: NSTimeInterval { return -age.timeIntervalSinceNow }
  var ageDisplay: String { return String(Int(ageInSeconds)) }
  
  var definitelyOld:   Bool { return ageInSeconds > Collie.definitelyOldTheshold   } // TODO: configurable per collection or model type
  var definitelyFresh: Bool { return ageInSeconds < Collie.definitelyFreshTheshold }
  
  /**
   ## About cache freshness
   * if definitelyOld, use greedy invalidation
   * if definitelyFresh, trust the local data, return immediately
   * In between these old and fresh times, use lazy invalidation strategy
   */
  var freshness: Collie.Freshness {
    // Collie.trace("ageInSeconds: \( age.timeIntervalSince1970 == 0 ? "Not Cached" : String(Int(ageInSeconds)) )")
    if definitelyOld { return .Old }
    if definitelyFresh { return .Fresh }
    return .Uncertain
  }
  
}







