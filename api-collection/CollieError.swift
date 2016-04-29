//
//  APIErrors.swift
//  api-collection
//
//  Created by Eric on 4/13/16.
//  Copyright © 2016 Simple Guy. All rights reserved.
//

import Foundation


enum CollieError: ErrorType {
  case CantParseNSDataToJsonDictionary
  case HTTPStatusError(code: Int)
  case CantParseNSHTTPURLResponse
  case CouldntCreateNSURL(url: String)
  case CouldntGetURLFromComponents(components: String)
  case NoDataOrError
  case JSONMissingId(json: Collie.JSON, idAttribute: String)
  case JSONUnknownTypeId(idValue: String, idAttribute: String)
}
