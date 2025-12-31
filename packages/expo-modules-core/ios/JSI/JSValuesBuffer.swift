// Copyright 2025-present 650 Industries. All rights reserved.

@available(iOS 16.4, *)
public struct JSValuesBuffer {
  internal weak var runtime: JSwiftRuntime?
  internal let bufferPointer: UnsafeBufferPointer<facebook.jsi.Value>

  public var count: Int {
    return bufferPointer.count
  }

  public init(_ runtime: JSwiftRuntime, start: consuming UnsafePointer<facebook.jsi.Value>, count: Int) {
    self.runtime = runtime
    self.bufferPointer = UnsafeBufferPointer(start: start, count: count)
  }

  public subscript(index: Int) -> JSwiftValue {
    guard let runtime else {
      JS.runtimeLostFatalError()
    }
    return JSwiftValue(runtime, facebook.jsi.Value(runtime.pointee, bufferPointer[index]))
  }
}
