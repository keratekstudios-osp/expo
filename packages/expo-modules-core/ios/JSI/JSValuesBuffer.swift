// Copyright 2025-present 650 Industries. All rights reserved.

@available(iOS 16.4, *)
public struct JSValuesBuffer: ~Copyable {
  internal weak var runtime: JavaScriptRuntime?
  internal let bufferPointer: UnsafeBufferPointer<facebook.jsi.Value>

  /**
   A pointer to the first value of the buffer.
   If the baseAddress of this buffer is `nil`, the `count` is zero.
   */
  public var baseAddress: UnsafePointer<facebook.jsi.Value>? {
    return bufferPointer.baseAddress
  }

  /**
   The number of values in the buffer.
   */
  public var count: Int {
    return bufferPointer.count
  }

  public init(_ runtime: JavaScriptRuntime, start: consuming UnsafePointer<facebook.jsi.Value>, count: Int) {
    self.runtime = runtime
    self.bufferPointer = UnsafeBufferPointer(start: start, count: count)
  }

  public init(_ runtime: JavaScriptRuntime, buffer: consuming UnsafeBufferPointer<facebook.jsi.Value>) {
    self.runtime = runtime
    self.bufferPointer = buffer
  }

  public subscript(index: Int) -> JavaScriptValue {
    guard let runtime else {
      JS.runtimeLostFatalError()
    }
    return JavaScriptValue(runtime, facebook.jsi.Value(runtime.pointee, bufferPointer[index]))
  }

  public func map<T>(_ transform: (_ value: consuming JavaScriptValue, _ index: Int) throws -> T) rethrows -> [T] {
    var result: [T] = []
    result.reserveCapacity(count)
    for index in 0..<count {
      result.append(try transform(self[index], index))
    }
    return result
  }

  public static func allocate(with values: [JSRepresentable], in runtime: JavaScriptRuntime) -> JSValuesBuffer {
    let buffer = UnsafeMutableBufferPointer<facebook.jsi.Value>.allocate(capacity: values.count)
    for (index, value) in values.enumerated() {
      buffer.initializeElement(at: index, to: value.toJSIValue(in: runtime.pointee))
    }
    return JSValuesBuffer(runtime, buffer: UnsafeBufferPointer(buffer))
  }

  public static func allocate(with values: JSRepresentable..., in runtime: JavaScriptRuntime) -> JSValuesBuffer {
    return allocate(with: values, in: runtime)
  }
}
