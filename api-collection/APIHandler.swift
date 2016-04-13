import Foundation



public func ==<T>(lhs: APIHandler<T>, rhs: APIHandler<T>) -> Bool {
  return unsafeAddressOf(lhs) == unsafeAddressOf(rhs)
}

/// A Hashable container for subscription methods. Swift has decided not to allow block comparison (essential for unique lists of function subscribers), so this wrapper is a workaround.
public class APIHandler<ModelType where ModelType: APIModel>: Hashable, Equatable {
  typealias onUpdateFn  = (items: [ModelType]) -> ()
  typealias onErrFn     = (error:  ErrorType ) -> ()
  
  let onUpdate: onUpdateFn
  let onErr: onErrFn?
  
  init(_ onUpdate: onUpdateFn, onErr: onErrFn? = nil) {
    self.onUpdate = onUpdate
    self.onErr = onErr
  }
  
  public var hashValue: Int {
    return unsafeAddressOf(self).hashValue
  }
}