// Copyright 2025-present 650 Industries. All rights reserved.

#import "Runtime.hpp"
#import "Object.hpp"

using namespace expo::jswift;

//void retainRuntime(CxxRuntime *) {
//  printf("DUPA retain\n");
//}
//
//void releaseRuntime(CxxRuntime *) {
//  printf("DUPA release\n");
//}

Runtime::Runtime(jsi::Runtime &runtime) {
  this->runtime = std::shared_ptr<jsi::Runtime>(std::shared_ptr<jsi::Runtime>(), &runtime);
//  this->runtime = std::shared_ptr<CxxRuntime>(std::shared_ptr<CxxRuntime>(), dynamic_cast<CxxRuntime *>(&runtime));
}

jsi::Runtime& Runtime::operator*() const {
  return *runtime;
}

Object Runtime::createObject() const {
  return Object(*this);
}
