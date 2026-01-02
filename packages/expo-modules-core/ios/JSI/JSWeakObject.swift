// Copyright 2025-present 650 Industries. All rights reserved.

public struct JavaScriptWeakObject: ~Copyable {
  internal weak var runtime: JavaScriptRuntime?
  internal let pointee: facebook.jsi.WeakObject

  public init(_ runtime: JavaScriptRuntime, _ object: consuming facebook.jsi.WeakObject) {
    self.runtime = runtime
    self.pointee = object
  }

  public func lock() -> JavaScriptObject {
    guard let runtime else {
      JS.runtimeLostFatalError()
    }
    return JavaScriptObject(runtime, pointee.lock(runtime.pointee).getObject(runtime.pointee))
  }
}
