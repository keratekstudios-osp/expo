// Copyright 2025-present 650 Industries. All rights reserved.

@available(iOS 16.4, *)
public struct JavaScriptObject: JSRepresentable, Sendable, ~Copyable {
  internal let runtime: JavaScriptRuntime
  internal var pointee: facebook.jsi.Object

  /**
   Creates a new object in the given runtime.
   */
  public init(_ runtime: JavaScriptRuntime) {
    self.init(runtime, facebook.jsi.Object(runtime.pointee))
  }

  /**
   Creates a new object from the dictionary whose values are representable in JS.
   */
  public init<DictValue: JSRepresentable>(_ runtime: JavaScriptRuntime, _ dictionary: [String: DictValue]) {
    self.runtime = runtime
    self.pointee = dictionary.toJSIValue(in: runtime.pointee).getObject(runtime.pointee)
  }

  /**
   Creates a new object from existing JSI object.
   - TODO: Make it internal
   */
  public init(_ runtime: JavaScriptRuntime, _ object: consuming facebook.jsi.Object) {
    self.runtime = runtime
    self.pointee = object
  }

  // MARK: - Accessing object properties

  public func hasProperty(_ name: String) -> Bool {
    return pointee.hasProperty(runtime.pointee, name)
  }

  public func getProperty(_ name: String) -> JavaScriptValue {
    return JavaScriptValue(runtime, pointee.getProperty(runtime.pointee, name))
  }

  public func getPropertyNames() -> [String] {
    let jsiRuntime = runtime.pointee
    let propertyNames: facebook.jsi.Array = pointee.getPropertyNames(jsiRuntime)
    let count = propertyNames.size(jsiRuntime)

    return (0..<count).map { i in
      return String(propertyNames.getValueAtIndex(jsiRuntime, i).getString(jsiRuntime).utf8(jsiRuntime))
    }
  }

  // MARK: - Modifying object properties

  public func setProperty(_ name: String, _ bool: Bool) {
    expo.jswift.setProperty(runtime.pointee, pointee, name, bool)
  }

  public func setProperty(_ name: String, _ double: Double) {
    expo.jswift.setProperty(runtime.pointee, pointee, name, double)
  }

  public func setProperty(_ name: String, value: consuming JavaScriptValue?) {
    let value = value ?? .null
    expo.jswift.setProperty(runtime.pointee, pointee, name, value.pointee)
  }

  public func setProperty(_ name: String, value: consuming JSRepresentable) {
    let jsiValue = value.toJSIValue(in: runtime.pointee)
    expo.jswift.setProperty(runtime.pointee, pointee, name, jsiValue)
  }

  public func setProperty(_ name: String, _ object: consuming JavaScriptObject) {
    expo.jswift.setProperty(runtime.pointee, pointee, name, facebook.jsi.Value(runtime.pointee, object.pointee))
  }

  public func deleteProperty(_ name: String) {
    pointee.deleteProperty(runtime.pointee, name)
  }

  public func defineProperty(_ name: String, descriptor: consuming JavaScriptObject) {
    expo.common.defineProperty(runtime.pointee, pointee, name, descriptor.pointee)
  }

  public func defineProperty(_ name: String, descriptor: consuming PropertyDescriptor = .init()) {
    let descriptorObject = descriptor.toObject(runtime)
    defineProperty(name, descriptor: descriptorObject)
  }

  public func defineProperty<Value: JSRepresentable & ~Copyable>(_ name: String, value: borrowing Value, options: PropertyOptions = []) {
    let descriptor = PropertyDescriptor(
      configurable: options.contains(.writable),
      enumerable: options.contains(.enumerable),
      writable: options.contains(.writable),
      value: value.toJSValue(in: runtime)
    )
    defineProperty(name, descriptor: descriptor)
  }

  // MARK: - Conversions

  public func toValue() -> JavaScriptValue {
    return JavaScriptValue(runtime, facebook.jsi.Value(runtime.pointee, pointee))
  }

  public func createWeak() -> JavaScriptWeakObject {
    return JavaScriptWeakObject(runtime, facebook.jsi.WeakObject(runtime.pointee, pointee))
  }

  // MARK: - Deallocator

  public func setObjectDeallocator(_ deallocator: @escaping () -> Void) {
    expo.common.setDeallocator(runtime.pointee, pointee, deallocator)
  }

  // MARK: - Memory pressure

  public func setExternalMemoryPressure(_ size: Int) {
    pointee.setExternalMemoryPressure(runtime.pointee, size)
  }

  // MARK: - JSRepresentable

  public static func fromJSIValue(_ value: borrowing facebook.jsi.Value, in runtime: facebook.jsi.Runtime) -> JavaScriptObject {
    fatalError()
  }

  public static func fromJSValue(_ value: borrowing JavaScriptValue) -> JavaScriptObject {
    return value.getObject()
  }

  public func toJSIValue(in runtime: facebook.jsi.Runtime) -> facebook.jsi.Value {
    return toValue().pointee
  }

  public func toJSValue(in runtime: JavaScriptRuntime) -> JavaScriptValue {
    return toValue()
  }
}

public struct PropertyOptions: OptionSet, Sendable {
  public let rawValue: Int
  
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
  
  public static let configurable = PropertyOptions(rawValue: 1 << 0)
  public static let enumerable = PropertyOptions(rawValue: 1 << 1)
  public static let writable = PropertyOptions(rawValue: 1 << 2)
}

@available(iOS 16.4, *)
public struct PropertyDescriptor: ~Copyable {
  let configurable: Bool
  let enumerable: Bool
  let writable: Bool
  let value: JavaScriptValue?

  public init(configurable: Bool = false, enumerable: Bool = false, writable: Bool = false, value: consuming JavaScriptValue? = nil) {
    self.configurable = configurable
    self.enumerable = enumerable
    self.writable = writable
    self.value = value
  }

  public consuming func toObject(_ runtime: borrowing JavaScriptRuntime) -> JavaScriptObject {
    let object = runtime.createObject()
    if configurable {
      object.setProperty("configurable", true)
    }
    if enumerable {
      object.setProperty("enumerable", true)
    }
    if writable {
      object.setProperty("writable", true)
    }
    if let value {
      object.setProperty("value", value: value)
    }
    return object
  }
}
