// Copyright 2025-present 650 Industries. All rights reserved.

#import <swift/bridging>

namespace facebook::jsi {
//class SWIFT_SHARED_REFERENCE(retainRuntime, releaseRuntime) Runtime;
class SWIFT_UNSAFE_REFERENCE Runtime;
}

#import "jsi.h"

namespace jsi = facebook::jsi;

namespace expo::jswift {

class Object;
class Value;

//class CxxRuntime : public jsi::Runtime {
//} SWIFT_SHARED_REFERENCE(retainRuntime, releaseRuntime);
//
//void retainRuntime(CxxRuntime *);
//void releaseRuntime(CxxRuntime *);

class SWIFT_PRIVATE_FILEID("ExpoModulesJSI/ExpoCxxRuntime.swift") Runtime {
  friend class Object;
  friend class Value;

private:
  std::shared_ptr<jsi::Runtime> runtime;

public:
  Runtime(jsi::Runtime &runtime);

  jsi::Runtime& operator*() const;

  Object createObject() const;
};

} // namespace expo::jswift
