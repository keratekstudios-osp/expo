// Copyright 2025-present 650 Industries. All rights reserved.

@available(iOS 16.4, *)
public struct JSwiftFunction: ~Copyable {
  internal weak var runtime: JSwiftRuntime?
  internal let pointee: facebook.jsi.Function

  public init(_ runtime: JSwiftRuntime?, _ pointee: consuming facebook.jsi.Function) {
    self.runtime = runtime
    self.pointee = pointee
  }

  public func call(arguments: Double...) -> JSwiftValue {
    guard let jsiRuntime = runtime?.pointee else {
      JS.runtimeLostFatalError()
    }
    let bufferPointer = UnsafeMutableBufferPointer<facebook.jsi.Value>.allocate(capacity: arguments.count)

    for (index, argument) in arguments.enumerated() {
      bufferPointer.initializeElement(at: index, to: facebook.jsi.Value(argument))
    }

    let result = pointee.call(jsiRuntime, bufferPointer.baseAddress, bufferPointer.count)
    return JSwiftValue(runtime, result)
  }

  public func toValue() -> JSwiftValue {
    guard let jsiRuntime = runtime?.pointee else {
      JS.runtimeLostFatalError()
    }
    return JSwiftValue(runtime, expo.valueFromFunction(jsiRuntime, pointee))
  }

  public func toObject() -> JSwiftObject {
    guard let runtime else {
      JS.runtimeLostFatalError()
    }
    let jsiRuntime = runtime.pointee
    return JSwiftObject(runtime, expo.valueFromFunction(jsiRuntime, pointee).getObject(jsiRuntime))
  }
}
