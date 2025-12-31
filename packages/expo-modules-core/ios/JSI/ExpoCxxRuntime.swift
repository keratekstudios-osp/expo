//import CxxStdlib

//@_expose(Cxx, "ExpoCxxRuntime")
//public class ExpoCxxRuntime {
//  internal var runtime: UnsafeMutablePointer<facebook.jsi.Runtime>
//
//  internal var pointee: facebook.jsi.Runtime {
//    get {
//      return runtime.pointee
//    }
//    set {
//      runtime.pointee = newValue
//    }
//  }
//
//  public init(runtime: UnsafeMutablePointer<facebook.jsi.Runtime>) {
//    self.runtime = runtime
//  }
//
//  public func createObject() -> ExpoCxxObject {
//    return ExpoCxxObject(self, facebook.jsi.Object(&runtime.pointee))
//  }
//}

//public class ExpoCxxObject {
//  internal var runtime: ExpoCxxJavaScriptRuntime
//  internal var object: UnsafePointer<facebook.jsi.Object>
//
//  public init(_ runtime: ExpoCxxJavaScriptRuntime, _ object: consuming facebook.jsi.Object) {
//    self.runtime = runtime
//    self.object = withUnsafePointer(to: &object) { $0 }
//  }
//}

//public typealias CxxRuntime = expo.jswift.Runtime
//public typealias CxxObject = expo.jswift.Object
//public typealias CxxValue = expo.jswift.Value

public extension expo.jswift.Runtime {
  func test() -> facebook.jsi.Object {
    return facebook.jsi.Object(runtime.pointee)
  }
}

public extension expo.jswift.Object {
  func getProperty(_ name: String) -> expo.jswift.Value {
    return __getProperty(name)
  }
  func getPropertyNames() -> [String] {
    return __getPropertyNames().map { String($0) }
  }
}

public extension expo.jswift.Value {}
