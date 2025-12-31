// Copyright 2025-present 650 Industries. All rights reserved.

@available(iOS 16.4, *)
public struct JSwiftObject: ~Copyable {
  internal let runtime: JSwiftRuntime
  internal var pointee: facebook.jsi.Object

  /**
   Creates a new object in the given runtime.
   */
  public init(_ runtime: JSwiftRuntime) {
    self.init(runtime, facebook.jsi.Object(runtime.pointee))
  }

  /**
   Creates a new object from the dictionary whose values are representable in JS.
   */
  public init<DictValue: JSRepresentable>(_ runtime: JSwiftRuntime, _ dictionary: [String: DictValue]) {
    self.runtime = runtime
    self.pointee = dictionary.toJSIValue(in: runtime.pointee).getObject(runtime.pointee)
  }

  /**
   Creates a new object from existing JSI object.
   */
  internal init(_ runtime: JSwiftRuntime, _ object: consuming facebook.jsi.Object) {
    self.runtime = runtime
    self.pointee = object
  }

  // MARK: - Accessing object properties

  public func hasProperty(_ name: String) -> Bool {
    return pointee.hasProperty(runtime.pointee, name)
  }

  public func getProperty(_ name: String) -> JSwiftValue {
    return JSwiftValue(runtime, pointee.getProperty(runtime.pointee, name))
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

  public func setProperty(_ name: String, _ value: consuming JSwiftValue?) {
    let value = value ?? .null
    expo.jswift.setProperty(runtime.pointee, pointee, name, value.pointee)
  }

  public func setProperty(_ name: String, _ object: consuming JSwiftObject) {
    expo.jswift.setProperty(runtime.pointee, pointee, name, facebook.jsi.Value(runtime.pointee, object.pointee))
  }

  public func deleteProperty(_ name: String) {
    pointee.deleteProperty(runtime.pointee, name)
  }

  public mutating func defineProperty(_ name: String, descriptor: consuming PropertyDescriptor = .init()) {
    // TODO: Make it non-mutating and don't use the unsafe mutable pointer
    let descriptorObject = descriptor.toObject(runtime)
    let unsafePtr = withUnsafeMutablePointer(to: &pointee) { $0 }

    expo.common.defineProperty(runtime.pointee, unsafePtr, name, descriptorObject.pointee)
  }

  // MARK: - Conversions

  public func toValue() -> JSwiftValue {
    return JSwiftValue(runtime, facebook.jsi.Value(runtime.pointee, pointee))
  }

  // MARK: - Deallocator

  public func setObjectDeallocator(_ deallocator: @escaping () -> Void) {
    expo.common.setDeallocator(runtime.pointee, pointee, deallocator)
  }

  // MARK: - Memory pressure

  public func setExternalMemoryPressure(_ size: Int) {
    pointee.setExternalMemoryPressure(runtime.pointee, size)
  }
}

@available(iOS 16.4, *)
public struct PropertyDescriptor: ~Copyable {
  let configurable: Bool
  let enumerable: Bool
  let writable: Bool
  let value: JSwiftValue?

  public init(configurable: Bool = false, enumerable: Bool = false, writable: Bool = false, value: consuming JSwiftValue? = nil) {
    self.configurable = configurable
    self.enumerable = enumerable
    self.writable = writable
    self.value = value
  }

  public consuming func toObject(_ runtime: borrowing JSwiftRuntime) -> JSwiftObject {
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
      object.setProperty("value", value)
    }
    return object
  }
}
