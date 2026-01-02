// Copyright 2025-present 650 Industries. All rights reserved.

public struct JavaScriptFunction: ~Copyable, JSRepresentable {
  internal weak var runtime: JavaScriptRuntime?
  internal let pointee: facebook.jsi.Function

  public init(_ runtime: JavaScriptRuntime?, _ pointee: consuming facebook.jsi.Function) {
    self.runtime = runtime
    self.pointee = pointee
  }

  // MARK: - Calling

  // TODO: Temporary specialized function, remove it
  public func call(arguments: Double...) -> JavaScriptValue {
    guard let jsiRuntime = runtime?.pointee else {
      JS.runtimeLostFatalError()
    }
    let bufferPointer = UnsafeMutableBufferPointer<facebook.jsi.Value>.allocate(capacity: arguments.count)

    for (index, argument) in arguments.enumerated() {
      bufferPointer.initializeElement(at: index, to: facebook.jsi.Value(argument))
    }

    let result = pointee.call(jsiRuntime, bufferPointer.baseAddress, bufferPointer.count)
    return JavaScriptValue(runtime, result)
  }

  /**
   Calls the function with the given `this` object and arguments.
   */
  public func call(this: consuming JavaScriptObject?, arguments: consuming JSValuesBuffer) throws -> JavaScriptValue {
    guard let runtime else {
      JS.runtimeLostFatalError()
    }
    let jsiResult = if let this {
      pointee.callWithThis(runtime.pointee, this.pointee, arguments.baseAddress, arguments.count)
    } else {
      pointee.call(runtime.pointee, arguments.baseAddress, arguments.count)
    }
    return JavaScriptValue(runtime, jsiResult)
  }

  /**
   Calls the function as a constructor with the given arguments. It's like calling a function with the `new` keyword.
   */
  public func callAsConstructor(_ arguments: consuming JSValuesBuffer) throws -> JavaScriptValue {
    guard let runtime else {
      JS.runtimeLostFatalError()
    }
    let jsiResult = pointee.callAsConstructor(runtime.pointee, arguments.baseAddress, arguments.count)
    return JavaScriptValue(runtime, jsiResult)
  }

  // MARK: - Conversions

  public func toValue() -> JavaScriptValue {
    guard let jsiRuntime = runtime?.pointee else {
      JS.runtimeLostFatalError()
    }
    return JavaScriptValue(runtime, expo.valueFromFunction(jsiRuntime, pointee))
  }

  public func toObject() -> JavaScriptObject {
    guard let runtime else {
      JS.runtimeLostFatalError()
    }
    let jsiRuntime = runtime.pointee
    return JavaScriptObject(runtime, expo.valueFromFunction(jsiRuntime, pointee).getObject(jsiRuntime))
  }

  // MARK: - JSRepresentable

  public static func fromJSIValue(_ value: borrowing facebook.jsi.Value, in runtime: facebook.jsi.Runtime) -> JavaScriptFunction {
    fatalError("Not implemented")
  }

  public static func fromJSValue(_ value: borrowing JavaScriptValue) -> JavaScriptFunction {
    return value.getFunction()
  }

  public func toJSIValue(in runtime: facebook.jsi.Runtime) -> facebook.jsi.Value {
    return toValue().pointee
  }

  public func toJSValue(in runtime: JavaScriptRuntime) -> JavaScriptValue {
    return toValue()
  }
}
