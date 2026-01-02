// Copyright 2025-present 650 Industries. All rights reserved.

@available(iOS 16.4, *)
open class JavaScriptRuntime: Equatable, @unchecked Sendable {
  // TODO: Make it internal
  public let pointee: facebook.jsi.Runtime
  internal let scheduler: expo.RuntimeScheduler

  /**
   Creates a runtime from a JSI runtime.
   */
  public init(_ runtime: facebook.jsi.Runtime) {
    self.pointee = runtime
    self.scheduler = expo.RuntimeScheduler(runtime)
  }

  /**
   Creates Hermes runtime.
   */
  public convenience init() {
    self.init(expo.createHermesRuntime())
  }

  /**
   Returns the runtime `global` object.
   */
  public func global() -> JavaScriptObject {
    return JavaScriptObject(self, pointee.global())
  }

  // MARK: - Creating objects

  /**
   Creates a plain JavaScript object.
   */
  public func createObject() -> JavaScriptObject {
    return JavaScriptObject(self, facebook.jsi.Object(pointee))
  }

  /**
   Creates a new JavaScript object, using the provided object as the prototype.
   Calls `Object.create(prototype)` under the hood.
   */
  public func createObject(prototype: consuming JavaScriptObject) -> JavaScriptObject {
    return JavaScriptObject(self, expo.common.createObjectWithPrototype(pointee, &prototype.pointee))
  }

  /**
   Creates a JavaScript host object with given implementations for property getter, property setter, property names getter and dealloc.
   */
  public func createHostObject(
    get: @escaping (_ propertyName: String) -> JavaScriptValue,
    set: @escaping (_ propertyName: String, _ value: consuming JavaScriptValue) -> Void,
    getPropertyNames: @escaping () -> [String],
    dealloc: @escaping () -> Void
  ) -> JavaScriptObject {
    return createObject()
//    let hostObject = expo.HostObject.makeObject(
//      pointee,
//      { (propertyName: std.string) in
//        return get(String(propertyName)).pointee
//      },
//      { (propertyName: std.string, value: consuming facebook.jsi.Value) in
//        set(String(propertyName), JavaScriptValue(self, value))
//      },
//      {
//        fatalError()
//      },
//      {
//        dealloc()
//      }
//    )
//    return JavaScriptObject(self, hostObject)
  }

  // MARK: - Creating functions

  /**
   Type of the closure that is passed to the `createSyncFunction` function.
   */
  public typealias SyncFunctionClosure = (_ this: consuming JavaScriptValue, _ arguments: consuming JSValuesBuffer) throws -> JavaScriptValue

  /**
   Creates a synchronous host function that runs the given closure when it's called.
   The value returned by the closure is synchronously returned to JS.
   - Returns: A JavaScript function represented as a `JavaScriptFunction`.
   */
  public func createSyncFunction(_ name: String, _ fn: @escaping SyncFunctionClosure) -> JavaScriptFunction {
    let hostFunction = expo.createHostFunction(pointee, name) { runtime, this, arguments, count in
      // Explicitly copy `this` as it's borrowed by the closure
      let this = JavaScriptValue(self, facebook.jsi.Value(runtime, this))
      let argumentsBuffer = JSValuesBuffer(self, start: arguments, count: count)

      // Remap a buffer with `jsi.Value` to a new buffer with `JavaScriptValue`
//      let jsiArgumentsBuffer = UnsafeMutableBufferPointer<facebook.jsi.Value>(start: UnsafeMutablePointer(mutating: arguments), count: count)
//      let argumentsBuffer = jsiArgumentsBuffer.remap({ JavaScriptValue(self, $0) })

      do {
        return try fn(this, argumentsBuffer).pointee
      } catch {
        // TODO: Implement throwing `facebook.jsi.JSError`, returns `undefined` until then
        return .undefined()
      }
    }
    return JavaScriptFunction(self, hostFunction)
  }

  /**
   Closure that modules use to resolve the JavaScript promise waiting for a result.
   */
  public typealias PromiseResolveClosure = @Sendable (_ result: borrowing JavaScriptValue) -> Void

  /**
   Closure that modules use to reject the JavaScript promise waiting for a result.
   The error may be nil but it is preferable to pass an `NSError` object for more precise error messages.
   */
  public typealias PromiseRejectClosure = @Sendable (_ code: String, _ message: String, _ error: (any Error)?) -> Void

  /**
   Type of the closure that is passed to the `createAsyncFunction` function.
   */
  public typealias AsyncFunctionClosure = @Sendable (
    _ this: consuming JavaScriptValue,
    _ arguments: consuming JSValuesBuffer,
    _ resolve: @escaping PromiseResolveClosure,
    _ reject: @escaping PromiseRejectClosure
  ) throws -> JavaScriptValue

  /**
   Creates an asynchronous host function that runs given block when it's called.
   The block receives a resolver that you should call when the asynchronous operation
   succeeds and a rejecter to call whenever it fails.
   \return A JavaScript function represented as a `JavaScriptObject`.
   */
  public func createAsyncFunction(_ name: String, _ fn: AsyncFunctionClosure) -> JavaScriptFunction {
    // TODO: Implement
    return createSyncFunction(name) { this, arguments in
//      let promiseSetup = { (runtime: facebook.jsi.Runtime, promise: Any) in
//        expo.callPromiseSetupWithBlock(runtime, callInvoker, promise) { (resolver, rejecter) in
//          fn(this, arguments, resolver, rejecter)
//        }
//      }
//      return facebook.react.createPromiseAsJSIValue(pointee, promiseSetup)
      return .undefined
    }
  }

  // MARK: - Runtime execution

  /**
   Schedules a closure to be executed with granted synchronized access to the runtime.
   */
  public func schedule(priority: SchedulerPriority = .normal, @_implicitSelfCapture _ closure: @escaping () -> Void) {
    let reactPriority = facebook.react.SchedulerPriority(rawValue: priority.rawValue) ?? .NormalPriority
    scheduler.scheduleTask(reactPriority, closure)
  }

  /**
   Priority of the scheduled task.
   - Note: Keep it in sync with the equivalent C++ enum from React Native (see `SchedulerPriority.h` from `React-callinvoker`).
   */
  public enum SchedulerPriority: Int32 {
    case immediate = 1
    case userBlocking = 2
    case normal = 3
    case low = 4
    case idle = 5
  }

  // MARK: - Script evaluation

  /**
   Evaluates given JavaScript source code.
   */
  @discardableResult
  public func eval(_ source: String) throws -> JavaScriptValue {
    let stringBuffer = expo.makeSharedStringBuffer(std.string(source))
    return JavaScriptValue(self, pointee.evaluateJavaScript(stringBuffer, std.string("<<evaluated>>")))
  }

  /**
   Evaluates the given JavaScript source code made by joining an array of strings with a newline separator.
   */
  @available(*, deprecated, message: "Spread the array into arguments instead")
  @discardableResult
  public func eval(_ lines: [String]) throws -> JavaScriptValue {
    try eval(lines.joined(separator: "\n"))
  }

  /**
   Evaluates the given JavaScript source code made by joining arguments with a newline separator.
   */
  @discardableResult
  public func eval(_ lines: String...) throws -> JavaScriptValue {
    try eval(lines.joined(separator: "\n"))
  }

  // MARK: - Equatable

  public static func == (lhs: JavaScriptRuntime, rhs: JavaScriptRuntime) -> Bool {
    return lhs === rhs
  }
}
