// Copyright 2025-present 650 Industries. All rights reserved.

public struct JavaScriptValue: JSRepresentable, Sendable, ~Copyable {
  internal weak var runtime: JavaScriptRuntime?
  internal let pointee: facebook.jsi.Value

  /**
   Initializer from the existing JSI value.
   */
  internal init(_ runtime: JavaScriptRuntime?, _ pointee: consuming facebook.jsi.Value) {
    self.runtime = runtime
    self.pointee = pointee
  }

  /**
   Copy initializer from the existing JSI value.
   */
  internal init(_ runtime: JavaScriptRuntime, _ pointee: borrowing facebook.jsi.Value) {
    self.runtime = runtime
    self.pointee = facebook.jsi.Value(runtime.pointee, pointee)
  }

  /**
   Creates a boolean JS value.
   */
  public init(_ runtime: JavaScriptRuntime, _ bool: Bool) {
    self.runtime = runtime
    self.pointee = facebook.jsi.Value(bool)
  }

  /**
   Creates an integer JS value.
   */
  public init(_ runtime: JavaScriptRuntime, _ integer: any BinaryInteger) {
    self.runtime = runtime
    self.pointee = facebook.jsi.Value(Int32(integer))
  }

  /**
   Creates a floating JS value.
   */
  public init(_ runtime: JavaScriptRuntime, _ float: any BinaryFloatingPoint) {
    self.runtime = runtime
    self.pointee = facebook.jsi.Value(Double(float))
  }

  /**
   Creates a JS value from a JS representable.
   */
  public init(_ runtime: JavaScriptRuntime, _ value: JSRepresentable) {
    self.runtime = runtime
    self.pointee = value.toJSIValue(in: runtime.pointee)
  }

  /**
   Copies the value.
   */
  public func copy() -> JavaScriptValue {
    guard let runtime else {
      JS.runtimeLostFatalError()
    }
    return JavaScriptValue(runtime, facebook.jsi.Value(runtime.pointee, pointee))
  }

  public func isUndefined() -> Bool {
    return pointee.isUndefined()
  }

  public func isNull() -> Bool {
    return pointee.isNull()
  }

  public func isBool() -> Bool {
    return pointee.isBool()
  }

  public func isNumber() -> Bool {
    return pointee.isNumber()
  }

  public func isString() -> Bool {
    return pointee.isString()
  }

  public func isSymbol() -> Bool {
    return pointee.isSymbol()
  }

  public func isObject() -> Bool {
    return pointee.isObject()
  }

  public func isArray() -> Bool {
    guard let jsiRuntime = runtime?.pointee else {
      JS.runtimeLostFatalError()
    }
    return pointee.isObject() && pointee.getObject(jsiRuntime).isArray(jsiRuntime)
  }

  public func isFunction() -> Bool {
    guard let jsiRuntime = runtime?.pointee else {
      JS.runtimeLostFatalError()
    }
    return pointee.isObject() && pointee.getObject(jsiRuntime).isFunction(jsiRuntime)
  }

  public func isTypedArray() -> Bool {
    guard let jsiRuntime = runtime?.pointee else {
      JS.runtimeLostFatalError()
    }
    return pointee.isObject() && expo.isTypedArray(jsiRuntime, pointee.getObject(jsiRuntime))
  }

  public func getBool() -> Bool {
    return pointee.getBool()
  }

  public func getInt() -> Int {
    return Int(pointee.getNumber())
  }

  public func getDouble() -> Double {
    return pointee.getNumber()
  }

  public func getString() -> String {
    guard let jsiRuntime = runtime?.pointee else {
      JS.runtimeLostFatalError()
    }
    return String(pointee.getString(jsiRuntime).utf8(jsiRuntime))
  }

  public func getObject() -> JavaScriptObject {
    guard let runtime else {
      JS.runtimeLostFatalError()
    }
    return JavaScriptObject(runtime, pointee.getObject(runtime.pointee))
  }

  public func getFunction() -> JavaScriptFunction {
    guard let runtime else {
      JS.runtimeLostFatalError()
    }
    return JavaScriptFunction(runtime, pointee.getObject(runtime.pointee).getFunction(runtime.pointee))
  }

  public func getTypedArray() -> JavaScriptTypedArray? {
    guard let runtime else {
      JS.runtimeLostFatalError()
    }
    guard isTypedArray() else {
      return nil
    }
    return JavaScriptTypedArray(runtime, expo.TypedArray(runtime.pointee, pointee.getObject(runtime.pointee)))
  }

  // MARK: - Kind

  public enum Kind: String {
    case undefined
    case null
    case bool
    case number
    case symbol
    case string
    case function
    case object
  }

  public var kind: Kind {
    // TODO: Make it a stored property, but computed on demand.
    // This feels like a better way to check value's type.
    switch true {
    case isUndefined():
      return .undefined
    case isNull():
      return .null
    case isBool():
      return .bool
    case isNumber():
      return .number
    case isSymbol():
      return .symbol
    case isString():
      return .string
    case isFunction():
      return .function
    default:
      return .object
    }
  }

  // MARK: - Equality

  /**
   Tests whether two values are strictly equal, according to https://262.ecma-international.org/11.0/#sec-strict-equality-comparison
   */
  public func isEqual(to another: borrowing JavaScriptValue) -> Bool {
    if let jsiRuntime = runtime?.pointee ?? another.runtime?.pointee {
      return facebook.jsi.Value.strictEquals(jsiRuntime, pointee, another.pointee)
    }
    // Some types don't have to be tied to any runtime. Since `strictEquals` needs a runtime, we need to handle this case ourselves.
    let thisKind = kind
    if thisKind != another.kind {
      return false
    }
    switch thisKind {
    case .undefined, .null:
      return true
    case .number:
      return getDouble() == another.getDouble()
    case .bool:
      return getBool() == another.getBool()
    default:
      return false
    }
  }

  /**
   Same as `isEqual(to:)`.
   */
  static func == (lhs: borrowing Self, rhs: borrowing Self) -> Bool {
    // Note that we implement comparison operator, but we don't add conformance to `Equatable` because it requires types to be copyable.
    // This proposal solves it: https://github.com/swiftlang/swift-evolution/blob/main/proposals/0499-support-non-copyable-simple-protocols.md
    return lhs.isEqual(to: rhs)
  }

  /**
   Negates the result of `isEqual(to:)`.
   */
  static func != (lhs: borrowing Self, rhs: borrowing Self) -> Bool {
    return !lhs.isEqual(to: rhs)
  }

  // MARK: - Runtime-free initializers

  public static var undefined: JavaScriptValue {
    return JavaScriptValue(nil, facebook.jsi.Value.undefined())
  }

  public static var null: JavaScriptValue {
    return JavaScriptValue(nil, facebook.jsi.Value.null())
  }

  public static var `true`: JavaScriptValue {
    return JavaScriptValue(nil, facebook.jsi.Value(true))
  }

  public static var `false`: JavaScriptValue {
    return JavaScriptValue(nil, facebook.jsi.Value(false))
  }

  public static func number(_ number: Double) -> JavaScriptValue {
    return JavaScriptValue(nil, facebook.jsi.Value(number))
  }

  public static func representing(value: JSRepresentable, in runtime: JavaScriptRuntime) -> JavaScriptValue {
    return value.toJSValue(in: runtime)
  }

  @available(*, deprecated, renamed: "representing(value:in:)")
  public static func from(_ value: Any, runtime: JavaScriptRuntime) -> JavaScriptValue {
    if let value = value as? JSRepresentable {
      return value.toJSValue(in: runtime)
    }
    return .undefined
  }

  // MARK: - JSRepresentable

  public static func fromJSIValue(_ value: borrowing facebook.jsi.Value, in runtime: facebook.jsi.Runtime) -> JavaScriptValue {
    fatalError("Not implemented")
  }

  public static func fromJSValue(_ value: borrowing JavaScriptValue) -> JavaScriptValue {
    return value.copy()
  }

  public func toJSIValue(in runtime: facebook.jsi.Runtime) -> facebook.jsi.Value {
    return facebook.jsi.Value(runtime, pointee)
  }

  public func toJSValue(in runtime: JavaScriptRuntime) -> JavaScriptValue {
    return self.copy()
  }
}
