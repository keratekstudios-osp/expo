// Copyright 2025-present 650 Industries. All rights reserved.

public enum JavaScriptValueKind: String {
  case undefined
  case null
  case bool
  case number
  case symbol
  case string
  case function
  case object
}

public extension JavaScriptValue {
  var kind: JavaScriptValueKind {
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
}
