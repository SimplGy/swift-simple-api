//
//  Here's how you define different API endpoints. Most apps will probably just have one, but multiple are supported
//

import Foundation


class APIs {

  // Waitress API
  static var waitress: CollieAPI = {
    let api = CollieAPI("https://waitress-live.appspot.com")
    api.headers["Accept"] = "application/vnd.waitress.v5+json"
    return api
  }()
  
  // Google Places API
  static var googlePlaces: CollieAPI = {
    let api = CollieAPI("https://maps.googleapis.com/maps/api/place")
    api.topLevelKey = "results"
    api.queryParams.append(NSURLQueryItem(name: "key", value: "AIzaSyAp_K45jvW741bDwypZsXocpeBKDxmEyjY"))
    return api
  }()
  
  // Star Wars API
  static var starWars: CollieAPI = {
    let api = CollieAPI("https://swapi.co/api")
    api.topLevelKey = "results"
    return api
  }()

}