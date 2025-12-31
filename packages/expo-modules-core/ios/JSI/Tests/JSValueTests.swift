// Copyright 2025-present 650 Industries. All rights reserved.

import Testing

@testable import ExpoModulesJSI

@Suite
struct JSValueTests {
  @Suite
  struct `isEqual(to:)` {
    let runtime = JSwiftRuntime()

    @Test
    func `true for itself`() {
      let a = JSwiftValue(runtime, "str")
      #expect(a.isEqual(to: a) == true)
    }

    @Test
    func `true for equal strings`() {
      let a = JSwiftValue(runtime, "str")
      let b = JSwiftValue(runtime, "str")
      #expect(a.isEqual(to: b) == true)
      #expect((a == b) == true)
    }

    @Test
    func `false for non-equal strings`() {
      let a = JSwiftValue(runtime, "strA")
      let b = JSwiftValue(runtime, "strB")
      #expect(a.isEqual(to: b) == false)
      #expect((a != b) == true)
    }

    @Test
    func `null does not strictly equal undefined`() {
      #expect(JSwiftValue.null.isEqual(to: .undefined) == false)
      #expect((JSwiftValue.null == JSwiftValue.undefined) == false)
    }

    @Test
    func `true for values pointing to the same object`() {
      let object = runtime.createObject()
      let a = object.toValue()
      let b = object.toValue()
      #expect(a.isEqual(to: b) == true)
    }

    @Test
    func `false for different objects`() {
      let a = runtime.createObject().toValue()
      let b = runtime.createObject().toValue()
      #expect(a.isEqual(to: b) == false)
    }
  }

  @Suite
  struct `static representing(value:in:)` {
    let runtime = JSwiftRuntime()

    @Test
    func `from boolean`() {
      let value = JSwiftValue.representing(value: true, in: runtime)
      #expect(value.isBool() == true)
    }

    @Test
    func `from integer`() {
      let value = JSwiftValue.representing(value: 123, in: runtime)
      #expect(value.isNumber() == true)
    }

    @Test
    func `from string`() {
      let value = JSwiftValue.representing(value: "str", in: runtime)
      #expect(value.isString() == true)
    }
  }
}
