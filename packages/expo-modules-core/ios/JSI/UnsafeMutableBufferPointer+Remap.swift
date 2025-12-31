// Copyright 2025-present 650 Industries. All rights reserved.

extension UnsafeMutableBufferPointer where Element: ~Copyable {
  consuming func remap<T: ~Copyable>(_ transform: (consuming Element) throws -> T) rethrows -> UnsafeBufferPointer<T> {
    let newBuffer = UnsafeMutableBufferPointer<T>.allocate(capacity: count)

    for index in (0..<count) {
      let element = moveElement(from: index)
      newBuffer.initializeElement(at: index, to: try transform(element))
    }
    return UnsafeBufferPointer(newBuffer)
  }
}
