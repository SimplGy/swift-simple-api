//
//  Internet Interface Static util methods
//

import Foundation


extension Collie {

  
  
  /**
   Get a collection of objects from an API endpoint
   
   - parameter urlPath: The trailing path for your collection, such as "/people/" or "/textsearch/json?query=Restaurants+in+Budapest"
   - parameter success: Callback for success
   - parameter failure: Callback for failure
   - parameter finally: Callback when either success or failure, called after both.
   
   - returns: NSURLSessionDataTask so you can cancel the request if you'd like
   */
  func getCollection(
    urlPath: String,
    success: ( (Collie.JSONArray) -> () ),
    failure: ( (ErrorType)        -> () )? = nil,
    finally: ( ()                 -> () )? = nil
  ) -> NSURLSessionDataTask? {
    
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
        self.trace("networking error: \(error)")
        failure?(error)
        finally?()
      
      // Unparsable Status
      } else if httpStatus == nil {
        self.trace("CantParseNSHTTPURLResponse")
        failure?(CollieError.CantParseNSHTTPURLResponse)
        finally?()
        
      // Bad Status
      } else if let httpStatus = httpStatus where httpStatus.statusCode != 200 {
        self.trace("statusCode should be 200, but is \(httpStatus.statusCode). Response: \(response)")
        failure?(CollieError.HTTPStatusError(code: httpStatus.statusCode))
        finally?()
        
      // All good in the hood
      } else if let data = data {
        do {
          let json = try CollieParse.jsonArrayFromData(data, topLevelKey: self.topLevelKey)
          success(json)
        } catch {
          self.trace("error converting response to JSONObjectWithData: \(error)")
          failure?(error)
        }
        finally?()
        
      // Unexpected. No data, no error.
      } else {
        print("CollieError.NoDataOrError")
        failure?(CollieError.NoDataOrError)
        finally?()
      }
      
    }
    
    task.resume()
    return task
  }

  

}