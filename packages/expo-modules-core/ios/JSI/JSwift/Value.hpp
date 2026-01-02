// Copyright 2025-present 650 Industries. All rights reserved.

#ifdef __cplusplus

#import "jsi.h"
#import <swift/bridging>

#import "Runtime.hpp"
#import "TypedArray.h"

namespace jsi = facebook::jsi;

namespace expo::jswift {

//class SWIFT_PRIVATE_FILEID("ExpoModulesJSI/ExpoCxxRuntime.swift") Value {
//  friend class Runtime;
//  friend class Object;
//
//private:
//  Runtime runtime;
//  jsi::Value pointee;
//
//public:
//  Value(Runtime &runtime) : runtime(runtime), pointee(jsi::Value()) {}
//  Value(Runtime &runtime, bool b) : runtime(runtime), pointee(jsi::Value(b)) {}
//  Value(Runtime &runtime, double d) : runtime(runtime), pointee(jsi::Value(d)) {}
//  Value(Runtime &runtime, int i) : runtime(runtime), pointee(jsi::Value(i)) {}
//  Value(Runtime &runtime, jsi::Value &&value) : runtime(runtime), pointee(std::move(value)) {}
//  Value(Runtime runtime, const jsi::Value &value) : runtime(runtime), pointee(jsi::Value(*runtime, value)) {}
//
//  Value(Runtime &runtime, const std::string &utf8String) : runtime(runtime) {
//    this->pointee = jsi::Value(*runtime, jsi::String::createFromUtf8(*runtime, utf8String));
//  }
//
//  inline bool isUndefined() const {
//    return pointee.isUndefined();
//  }
//
//  inline bool isNull() const {
//    return pointee.isNull();
//  }
//
//  inline bool isBool() const {
//    return pointee.isBool();
//  }
//
//  inline bool isNumber() const {
//    return pointee.isNumber();
//  }
//
//  inline bool isString() const {
//    return pointee.isString();
//  }
//
//  inline bool isSymbol() const {
//    return pointee.isSymbol();
//  }
//
//  inline bool isObject() const {
//    return pointee.isObject();
//  }
//
//  inline bool isFunction() const {
//    return pointee.isObject() && pointee.getObject(*runtime).isFunction(*runtime);
//  }
//
//  inline bool isTypedArray() const {
//    return pointee.isObject() && expo::isTypedArray(*runtime, pointee.getObject(*runtime));
//  }
//
//  inline bool getBool() const {
//    return pointee.getBool();
//  }
//
//  inline int getInt() const {
//    return pointee.getNumber();
//  }
//
//  inline double getDouble() const {
//    return pointee.getNumber();
//  }
//
//  const std::string getString() const {
//    return pointee.getString(*runtime).utf8(*runtime);
//  }
//
//  // getArray
//  // getDictionary
//  // getObject
//  // getFunction
//  // getTypedArray
//};

} // namespace expo::jswift

#endif // __cplusplus
