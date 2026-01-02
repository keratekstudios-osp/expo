// Copyright 2025-present 650 Industries. All rights reserved.

import ExpoModulesJSI

/**
 Class that extends the standard JavaScript runtime with some Expo-specific features.
 For instance, the global `expo` object is available only in Expo runtimes.
 */
public class ExpoRuntime: JavaScriptRuntime, @unchecked Sendable {
  @JavaScriptActor
  internal func getCoreObject() throws -> JavaScriptObject {
    return try global().getProperty(EXGlobalCoreObjectPropertyName).asObject()
  }

  @JavaScriptActor
  internal func createNativeModuleObject() throws -> JavaScriptObject {
    return JavaScriptObject(self, expo.NativeModule.createInstance(pointee))
  }

  @JavaScriptActor
  internal func getSharedObjectClass() throws -> JavaScriptObject {
    return try getCoreObject().getProperty("SharedObject").asObject()
  }

  @JavaScriptActor
  internal func getSharedRefClass() throws -> JavaScriptObject {
    return try getCoreObject().getProperty("SharedRef").asObject()
  }

  @JavaScriptActor
  internal func createSharedObjectClass(_ name: String, constructor: SyncFunctionClosure) -> JavaScriptObject {
    fatalError()
  }

  @JavaScriptActor
  internal func createSharedRefClass(_ name: String, constructor: SyncFunctionClosure) -> JavaScriptObject {
    fatalError()
  }
}
