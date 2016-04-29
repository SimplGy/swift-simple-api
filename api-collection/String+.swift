//
//  Enhancements for the String class
//


import Foundation

extension String {
  
  func fixedWidth(amount: Int) -> String {
    return self.stringByPaddingToLength(amount, withString: " ", startingAtIndex: 0)
  }
  
}