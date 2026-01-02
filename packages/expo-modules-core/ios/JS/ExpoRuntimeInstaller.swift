// Copyright 2025-present 650 Industries. All rights reserved.

import ExpoModulesJSI

@JavaScriptActor
internal struct ExpoRuntimeInstaller {
  private let appContext: AppContext
  private let runtime: ExpoRuntime

  internal init(appContext: AppContext, runtime: ExpoRuntime) {
    self.appContext = appContext
    self.runtime = runtime
  }

  internal func installExpoObject(_ object: borrowing JavaScriptObject) throws {
    runtime.global().defineProperty(EXGlobalCoreObjectPropertyName, value: object, options: [.enumerable])

    // Install `global.expo.EventEmitter`.
    installEventEmitterClass()

    // Install `global.expo.SharedObject`.
    installSharedObjectClass() { [weak appContext] objectId in
      appContext?.sharedObjectRegistry.delete(objectId)
    }

    // Install `global.expo.SharedRef`.
    installSharedRefClass()

    // Install `global.expo.NativeModule`.
    installNativeModuleClass()

    // Install the modules host object as the `global.expo.modules`.
    try installExpoModulesHostObject()
  }

  private func installSharedObjectClass(_ releaser: @escaping (_ objectId: SharedObjectId) -> Void) {
    expo.SharedObject.installBaseClass(runtime.pointee) { objectId in
      releaser(objectId)
    }
  }

  private func installSharedRefClass() {
    expo.SharedRef.installBaseClass(runtime.pointee)
  }

  private func installEventEmitterClass() {
    expo.EventEmitter.installClass(runtime.pointee);
  }

  private func installNativeModuleClass() {
    expo.NativeModule.installClass(runtime.pointee)
  }

  private func installExpoModulesHostObject() throws {
    let coreObject = try runtime.getCoreObject()

    if coreObject.hasProperty("modules") {
      // Host object already installed
      return
    }
    let modulesHostObject = runtime.createHostObject(
      get: { propertyName in
        return .undefined
      },
      set: { propertyName, value in},
      getPropertyNames: { [] },
      dealloc: {}
    )
    coreObject.defineProperty("modules", value: modulesHostObject.toValue(), options: [.enumerable])
  }
}
