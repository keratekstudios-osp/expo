// Copyright 2025-present 650 Industries. All rights reserved.

#import "jsi.h"
#import <swift/bridging>

#import "Runtime.hpp"
#import "Value.hpp"
#import "JSIUtils.h"

namespace jsi = facebook::jsi;

namespace expo::jswift {

const Object objectFromPropertyDescriptor(Runtime runtime, const common::PropertyDescriptor &descriptor);

class SWIFT_PRIVATE_FILEID("ExpoModulesJSI/ExpoCxxRuntime.swift") Object {
  friend class Runtime;

private:
  Runtime runtime;
  jsi::Object pointee;

  Object(Runtime runtime);

public:
  inline bool hasProperty(const char *name) const {
    return pointee.hasProperty(*runtime, name);
  }

  inline Value getProperty(const char *name) const SWIFT_NAME(__getProperty(_:)) {
    return Value(runtime, pointee.getProperty(*runtime, name));
  }

  inline void setProperty(const char *name, bool value) const {
    pointee.setProperty(*runtime, name, value);
  }

  inline void setProperty(const char *name, double value) const {
    pointee.setProperty(*runtime, name, value);
  }

  inline void setProperty(const char *name, int value) const {
    pointee.setProperty(*runtime, name, value);
  }

  inline void setProperty(const char *name, const Value &value) const {
    pointee.setProperty(*runtime, name, value.pointee);
  }

  inline void defineProperty(const char *name, Object &descriptor) {
//    common::defineProperty(*runtime, &pointee, name, descriptor.pointee);
  }

  inline void defineProperty(const char *name, const common::PropertyDescriptor &descriptor) const {
    Object object = objectFromPropertyDescriptor(runtime, descriptor);
    pointee.setProperty(*runtime, name, object.pointee);
  }

  // Some functions needs to be refined in Swift
private:
  std::vector<std::string> getPropertyNames() const SWIFT_NAME(__getPropertyNames());
};

// `jsi::Object::setProperty` is a template function that Swift does not support. We need to provide specialized versions.
void setProperty(jsi::Runtime &runtime, const jsi::Object &object, const char *name, bool value);
void setProperty(jsi::Runtime &runtime, const jsi::Object &object, const char *name, double value);
void setProperty(jsi::Runtime &runtime, const jsi::Object &object, const char *name, const jsi::Value value);
void setValueAtIndex(jsi::Runtime &runtime, const jsi::Array &array, size_t index, const jsi::Value value);
jsi::Value arrayToValue(jsi::Runtime &runtime, const jsi::Array &array);

} // namespace expo::jswift
