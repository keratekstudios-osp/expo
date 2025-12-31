// Copyright 2025-present 650 Industries. All rights reserved.

@available(iOS 16.4, *)
public struct JS {
  public typealias Runtime = JSwiftRuntime
  public typealias Value = JSwiftValue
  public typealias Object = JSwiftObject
  public typealias Function = JSwiftFunction

  public static func runtimeLostFatalError() -> Never {
    fatalError("The JavaScript runtime has been deallocated")
  }
}
