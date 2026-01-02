// Copyright 2025-present 650 Industries. All rights reserved.

/**
 A type whose values can be represented in the JS runtime.
 */
public protocol JSRepresentable: Sendable, ~Copyable {
  /**
   Creates an instance of this type from the given `facebook.jsi.Value` in `facebook.jsi.Runtime`.
   */
  static func fromJSIValue(_ value: borrowing facebook.jsi.Value, in runtime: facebook.jsi.Runtime) -> Self
  /**
   Creates an instance of this type from the given JS value.
   */
  static func fromJSValue(_ value: borrowing JavaScriptValue) -> Self
  /**
   Creates a JSI value representing this value in the given JSI runtime.
   */
  func toJSIValue(in runtime: facebook.jsi.Runtime) -> facebook.jsi.Value
  /**
   Creates a JS value representing this value in the given runtime.
   */
  func toJSValue(in runtime: JavaScriptRuntime) -> JavaScriptValue
}

public extension JSRepresentable {
  static func fromJSIValue(_ value: borrowing facebook.jsi.Value, in runtime: facebook.jsi.Runtime) -> Self {
    fatalError("Unimplemented")
  }

  static func fromJSValue(_ value: borrowing JavaScriptValue) -> Self {
    guard let jsiRuntime = value.runtime else {
      JS.runtimeLostFatalError()
    }
    return fromJSIValue(value.pointee, in: jsiRuntime.pointee)
  }

  func toJSIValue(in runtime: facebook.jsi.Runtime) -> facebook.jsi.Value {
    fatalError("Unimplemented")
  }

  func toJSValue(in runtime: JavaScriptRuntime) -> JavaScriptValue {
    return JavaScriptValue(runtime, toJSIValue(in: runtime.pointee))
  }
}

extension Bool: JSRepresentable {
  public static func fromJSIValue(_ value: borrowing facebook.jsi.Value, in runtime: facebook.jsi.Runtime) -> Bool {
    return value.getBool()
  }

  public func toJSIValue(in runtime: facebook.jsi.Runtime) -> facebook.jsi.Value {
    return facebook.jsi.Value(self)
  }
}

public protocol JSRepresentableNumber: JSRepresentable {}

extension JSRepresentableNumber {
  public static func fromJSIValue(_ value: borrowing facebook.jsi.Value, in runtime: facebook.jsi.Runtime) -> Int where Self: FixedWidthInteger {
    return Int(value.getNumber())
  }

  public static func fromJSIValue(_ value: borrowing facebook.jsi.Value, in runtime: facebook.jsi.Runtime) -> Double where Self: BinaryFloatingPoint {
    return value.getNumber()
  }

  public func toJSIValue(in runtime: facebook.jsi.Runtime) -> facebook.jsi.Value where Self: FixedWidthInteger {
    return facebook.jsi.Value(Int32(self))
  }

  public func toJSIValue(in runtime: facebook.jsi.Runtime) -> facebook.jsi.Value where Self: BinaryFloatingPoint {
    return facebook.jsi.Value(Double(self))
  }
}

extension Int: JSRepresentableNumber {}
extension Int8: JSRepresentableNumber {}
extension Int16: JSRepresentableNumber {}
extension Int32: JSRepresentableNumber {}
extension Int64: JSRepresentableNumber {}
extension UInt: JSRepresentableNumber {}
extension UInt8: JSRepresentableNumber {}
extension UInt16: JSRepresentableNumber {}
extension UInt32: JSRepresentableNumber {}
extension UInt64: JSRepresentableNumber {}
extension Float16: JSRepresentableNumber {}
extension Float32: JSRepresentableNumber {}
extension Float64: JSRepresentableNumber {}
extension CGFloat: JSRepresentableNumber {}

extension String: JSRepresentable {
  public static func fromJSIValue(_ value: borrowing facebook.jsi.Value, in runtime: facebook.jsi.Runtime) -> String {
    return String(value.getString(runtime).utf8(runtime))
  }

  public func toJSIValue(in runtime: facebook.jsi.Runtime) -> facebook.jsi.Value {
    return facebook.jsi.Value(runtime, facebook.jsi.String.createFromUtf8(runtime, std.string(self)))
  }
}

extension Optional: JSRepresentable where Wrapped: JSRepresentable {
  public static func fromJSIValue(_ value: borrowing facebook.jsi.Value, in runtime: facebook.jsi.Runtime) -> Self {
    if value.isNull() || value.isUndefined() {
      return nil
    }
    return Wrapped.fromJSIValue(value, in: runtime)
  }

  public func toJSIValue(in runtime: facebook.jsi.Runtime) -> facebook.jsi.Value {
    return self?.toJSIValue(in: runtime) ?? .null()
  }
}

extension Dictionary: JSRepresentable where Key == String {
  public static func fromJSIValue(_ value: borrowing facebook.jsi.Value, in runtime: facebook.jsi.Runtime) -> Dictionary<Key, Value> {
    let object = value.getObject(runtime)
    let propertyNames = object.getPropertyNames(runtime)
    let size = propertyNames.size(runtime)
    var result: Self = [:]

    for index in 0..<size {
      let jsiKey = propertyNames.getValueAtIndex(runtime, index)
      let key = String.fromJSIValue(jsiKey, in: runtime)
      let jsiValue = object.getProperty(runtime, jsiKey)
//      let value = Value.fromJSIValue(jsiValue, in: runtime)
//      result[key] = value
    }
    return result
  }

  public func toJSIValue(in runtime: facebook.jsi.Runtime) -> facebook.jsi.Value {
    let object = facebook.jsi.Object(runtime)

    for (key, value) in self {
      let keyString = String(describing: key)

      if let value = value as? JSRepresentable {
        expo.jswift.setProperty(runtime, object, keyString, value.toJSIValue(in: runtime))
      } else {
        expo.jswift.setProperty(runtime, object, keyString, .null())
      }
    }
    return facebook.jsi.Value(runtime, object)
  }
}

extension Array: JSRepresentable where Element: JSRepresentable {
  public static func fromJSIValue(_ value: borrowing facebook.jsi.Value, in runtime: facebook.jsi.Runtime) -> Array<Element> {
    let jsiArray = value.getObject(runtime).getArray(runtime)
    let size = jsiArray.size(runtime)
    var result: Self = []

    result.reserveCapacity(size)

    for index in 0..<size {
      result.append(Element.fromJSIValue(jsiArray.getValueAtIndex(runtime, index), in: runtime))
    }
    return result
  }
  
  public func toJSIValue(in runtime: facebook.jsi.Runtime) -> facebook.jsi.Value {
    let jsiArray = facebook.jsi.Array(runtime, count)

    for index in 0..<count {
      expo.jswift.setValueAtIndex(runtime, jsiArray, index, self[index].toJSIValue(in: runtime))
    }
    return expo.jswift.arrayToValue(runtime, jsiArray)
  }
}
