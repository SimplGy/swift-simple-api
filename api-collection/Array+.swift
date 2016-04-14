//
//  Enhancements for the foundation Array class
//


import Foundation

extension Array {
  
  /**
   *  Index into an array of questionable repute, returning an optional so you can go out of bounds without a runtime error
   */
  subscript (safe index: Int) -> Element? {
    return self.indices ~= index
      ? self[index]
      : nil
  }

}