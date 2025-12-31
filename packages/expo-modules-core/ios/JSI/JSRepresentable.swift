// Copyright 2025-present 650 Industries. All rights reserved.

/**
 A type whose values can be represented in the JS runtime.
 */
@available(iOS 16.4, *)
public protocol JSRepresentable {
  /**
   Creates an instance of this type from the given `facebook.jsi.Value` in `facebook.jsi.Runtime`.
   */
  static func fromJSIValue(_ value: borrowing facebook.jsi.Value, in runtime: facebook.jsi.Runtime) -> Self
  /**
   Creates an instance of this type from the given JS value.
   */
  static func fromJSValue(_ value: borrowing JSwiftValue) -> Self
  /**
   Creates a JSI value representing this value in the given JSI runtime.
   */
  func toJSIValue(in runtime: facebook.jsi.Runtime) -> facebook.jsi.Value
  /**
   Creates a JS value representing this value in the given runtime.
   */
  func toJSValue(in runtime: JSwiftRuntime) -> JSwiftValue
}

@available(iOS 16.4, *)
public extension JSRepresentable {
  static func fromJSValue(_ value: borrowing JSwiftValue) -> Self {
    guard let jsiRuntime = value.runtime else {
      JS.runtimeLostFatalError()
    }
    return fromJSIValue(value.pointee, in: jsiRuntime.pointee)
  }

  func toJSValue(in runtime: JSwiftRuntime) -> JSwiftValue {
    return JSwiftValue(runtime, toJSIValue(in: runtime.pointee))
  }
}

@available(iOS 16.4, *)
extension Bool: JSRepresentable {
  public static func fromJSIValue(_ value: borrowing facebook.jsi.Value, in runtime: facebook.jsi.Runtime) -> Bool {
    return value.getBool()
  }

  public func toJSIValue(in runtime: facebook.jsi.Runtime) -> facebook.jsi.Value {
    return facebook.jsi.Value(self)
  }
}

@available(iOS 16.4, *)
extension Int: JSRepresentable {
  public static func fromJSIValue(_ value: borrowing facebook.jsi.Value, in runtime: facebook.jsi.Runtime) -> Int {
    return Int(value.getNumber())
  }

  public func toJSIValue(in runtime: facebook.jsi.Runtime) -> facebook.jsi.Value {
    return facebook.jsi.Value(Int32(self))
  }
}

@available(iOS 16.4, *)
extension Double: JSRepresentable {
  public static func fromJSIValue(_ value: borrowing facebook.jsi.Value, in runtime: facebook.jsi.Runtime) -> Double {
    return value.getNumber()
  }

  public func toJSIValue(in runtime: facebook.jsi.Runtime) -> facebook.jsi.Value {
    return facebook.jsi.Value(self)
  }
}

@available(iOS 16.4, *)
extension String: JSRepresentable {
  public static func fromJSIValue(_ value: borrowing facebook.jsi.Value, in runtime: facebook.jsi.Runtime) -> String {
    return String(value.getString(runtime).utf8(runtime))
  }

  public func toJSIValue(in runtime: facebook.jsi.Runtime) -> facebook.jsi.Value {
    return facebook.jsi.Value(runtime, facebook.jsi.String.createFromUtf8(runtime, std.string(self)))
  }
}

@available(iOS 16.4, *)
extension Dictionary: JSRepresentable where Key == String, Value: JSRepresentable {
  public static func fromJSIValue(_ value: borrowing facebook.jsi.Value, in runtime: facebook.jsi.Runtime) -> Dictionary<Key, Value> {
    let object = value.getObject(runtime)
    let propertyNames = object.getPropertyNames(runtime)
    let size = propertyNames.size(runtime)
    var result: Self = [:]

    for index in 0..<size {
      let jsiKey = propertyNames.getValueAtIndex(runtime, index)
      let key = String.fromJSIValue(jsiKey, in: runtime)
      let jsiValue = object.getProperty(runtime, jsiKey)
      let value = Value.fromJSIValue(jsiValue, in: runtime)
      result[key] = value
    }
    return result
  }

  public func toJSIValue(in runtime: facebook.jsi.Runtime) -> facebook.jsi.Value {
    let object = facebook.jsi.Object(runtime)

    for (key, value) in self {
      let keyString = String(describing: key)
      expo.jswift.setProperty(runtime, object, keyString, value.toJSIValue(in: runtime))
    }
    return facebook.jsi.Value(runtime, object)
  }
}

@available(iOS 16.4, *)
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
