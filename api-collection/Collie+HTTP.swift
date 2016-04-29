//
//  Internet Interface Static util methods
//

import Foundation


extension Collie {

  
  
  /**
   Get a collection of objects from an API endpoint
   
   - parameter urlPath: The trailing path for your collection, such as "/people/" or "/textsearch/json?query=Restaurants+in+Budapest"
   - parameter modelType: The string name of the type of object you are getting for correct cache storage
   - parameter success: Callback for success. Note: because of lazy invalidation, this method may be called twice if there is a cache of uncertain status found.
   - parameter failure: Callback for failure. optional. default implementation logs a trace of the error
   - parameter finally: Callback when either success or failure, called after both. Only called once, even for lazy invalidation behavior.
   
   - returns: NSURLSessionDataTask so you can cancel the request if you'd like
   */
  func getCollection (
    urlPath: String,
    modelType: String,
    success: ( (Collie.JSONArray) -> () ),
    failure: ( (ErrorType)        -> () )? = { Collie.trace("\($0)") },
    finally: ( ()                 -> () )? = nil
  ) -> NSURLSessionDataTask? {
    
    // Do we have a cached value for this path?
    if let cache = CollieCache.getCollection(type: modelType, key: urlPath) {
      
      switch cache.freshness {
      case .Fresh:
        Collie.trace("Definitely fresh \(modelType)['\(urlPath)']: \(cache)")
        success(cache.jsonArray)
        finally?()
        return nil
      case .Uncertain:
        success(cache.jsonArray) // report success, but continue on to make the request as usual
      case .Old:
        break // nothing, just make the request as normal
      }
      
    }
    
    let fullUrl = self.rootURL + urlPath
    guard let urlComponents = NSURLComponents(string: fullUrl) else { print(CollieError.CouldntCreateNSURL(url: fullUrl)); return nil }
    
    urlComponents.queryItems = (urlComponents.queryItems ?? []) + self.queryParams
    guard let url = urlComponents.URL else { print(CollieError.CouldntGetURLFromComponents(components: "\(urlComponents)")); return nil }
    
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = "GET"
    request.timeoutInterval = self.timeout
    for (key, val) in self.headers {
      request.setValue(val, forHTTPHeaderField: key)
    }
    
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
      let httpStatus = response as? NSHTTPURLResponse
      
      // Networking Error
      if let error = error {
        failure?(error)
        finally?()
      
      // Unparsable Status
      } else if httpStatus == nil {
        failure?(CollieError.CantParseNSHTTPURLResponse)
        finally?()
        
      // Bad Status
      } else if let httpStatus = httpStatus where httpStatus.statusCode != 200 {
        failure?(CollieError.HTTPStatusError(code: httpStatus.statusCode))
        finally?()
        
      // All good in the hood
      } else if let data = data {
        do {
          let jsonArray = try CollieParse.jsonArrayFromData(data, topLevelKey: self.topLevelKey)
          
          // Successful data. Cache it.
          try CollieCache.storeCollection(type: modelType, key: urlPath, idAttribute: self.idAttribute, results: jsonArray)
          
          success(jsonArray)
        } catch {
          failure?(error)
        }
        finally?()
        
      // Unexpected. No data, no error.
      } else {
        failure?(CollieError.NoDataOrError)
        finally?()
      }
      
    }
    
    task.resume()
    return task
  }

  

}