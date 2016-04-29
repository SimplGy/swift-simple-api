//
//  Enhancements for the String class
//


import Foundation

extension String {
  
  func lockWidth(amount: Int) -> String {
    return self.stringByPaddingToLength(amount, withString: " ", startingAtIndex: 0)
  }
  
}