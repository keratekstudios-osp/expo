// Copyright 2025-present 650 Industries. All rights reserved.

@available(iOS 16.4, *)
open class JSwiftRuntime {
  internal let pointee: facebook.jsi.Runtime
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
  public func global() -> JSwiftObject {
    return JSwiftObject(self, pointee.global())
  }

  // MARK: - Creating objects

  /**
   Creates a plain JavaScript object.
   */
  public func createObject() -> JSwiftObject {
    return JSwiftObject(self, facebook.jsi.Object(pointee))
  }

  /**
   Creates a new JavaScript object, using the provided object as the prototype.
   Calls `Object.create(prototype)` under the hood.
   */
  public func createObject(prototype: consuming JSwiftObject) -> JSwiftObject {
    return JSwiftObject(self, expo.common.createObjectWithPrototype(pointee, &prototype.pointee))
  }

  // MARK: - Creating functions

  /**
   Type of the closure that is passed to the `createSyncFunction` function.
   */
  public typealias SyncFunctionClosure = @Sendable (_ this: consuming JSwiftValue, _ arguments: JSValuesBuffer) throws -> JSwiftValue

  /**
   Creates a synchronous host function that runs the given closure when it's called.
   The value returned by the closure is synchronously returned to JS.
   - Returns: A JavaScript function represented as a `JSwiftFunction`.
   */
  public func createSyncFunction(_ name: String, _ fn: @escaping SyncFunctionClosure) -> JSwiftFunction {
    let hostFunction = expo.createHostFunction(pointee, name) { runtime, this, arguments, count in
      // Explicitly copy `this` as it's borrowed by the closure
      let this = JSwiftValue(self, facebook.jsi.Value(runtime, this))
      let argumentsBuffer = JSValuesBuffer(self, start: arguments, count: count)

      // Remap a buffer with `jsi.Value` to a new buffer with `JSwiftValue`
//      let jsiArgumentsBuffer = UnsafeMutableBufferPointer<facebook.jsi.Value>(start: UnsafeMutablePointer(mutating: arguments), count: count)
//      let argumentsBuffer = jsiArgumentsBuffer.remap({ JSwiftValue(self, $0) })

      do {
        return try fn(this, argumentsBuffer).pointee
      } catch {
        // TODO: Implement throwing `facebook.jsi.JSError`, returns `undefined` until then
        return .undefined()
      }
    }
    return JSwiftFunction(self, hostFunction)
  }

  /**
   Closure that modules use to resolve the JavaScript promise waiting for a result.
   */
  public typealias PromiseResolveClosure = @Sendable (_ result: Any) -> Void

  /**
   Closure that modules use to reject the JavaScript promise waiting for a result.
   The error may be nil but it is preferable to pass an `NSError` object for more precise error messages.
   */
  public typealias PromiseRejectClosure = @Sendable (_ code: String, _ message: String, _ error: inout NSError) -> Void

  /**
   Type of the closure that is passed to the `createAsyncFunction` function.
   */
  public typealias AsyncFunctionClosure = @Sendable (
    _ this: consuming JSwiftValue,
    _ arguments: UnsafeBufferPointer<JSwiftValue>,
    _ resolve: PromiseResolveClosure,
    _ reject: PromiseRejectClosure
  ) -> JSwiftValue

  /**
   Creates an asynchronous host function that runs given block when it's called.
   The block receives a resolver that you should call when the asynchronous operation
   succeeds and a rejecter to call whenever it fails.
   \return A JavaScript function represented as a `JavaScriptObject`.
   */
  public func createAsyncFunction(_ name: String, _ fn: AsyncFunctionClosure) -> JSwiftFunction {
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
  public func eval(_ source: String) throws -> JSwiftValue {
    let stringBuffer = expo.makeSharedStringBuffer(std.string(source))
    return JSwiftValue(self, pointee.evaluateJavaScript(stringBuffer, std.string("<<evaluated>>")))
  }

  /**
   Evaluates the given JavaScript source code made by joining an array of strings with a newline separator.
   */
  @available(*, deprecated, message: "Spread the array into arguments instead")
  @discardableResult
  public func eval(_ lines: [String]) throws -> JSwiftValue {
    try eval(lines.joined(separator: "\n"))
  }

  /**
   Evaluates the given JavaScript source code made by joining arguments with a newline separator.
   */
  @discardableResult
  public func eval(_ lines: String...) throws -> JSwiftValue {
    try eval(lines.joined(separator: "\n"))
  }
}
