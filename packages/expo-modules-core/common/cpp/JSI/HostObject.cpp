// Copyright 2025-present 650 Industries. All rights reserved.

#import "HostObject.hpp"

namespace expo {

HostObject::HostObject(GetFunction get, SetFunction set, GetPropertyNamesFunction getPropertyNames, DeallocFunction dealloc)
: _get(get), _set(set), _getPropertyNames(getPropertyNames), _dealloc(dealloc) {}

HostObject::~HostObject() {
  _dealloc();
}

jsi::Value HostObject::get(jsi::Runtime &runtime, const jsi::PropNameID &name) {
  return _get(name.utf8(runtime));
}

void HostObject::set(jsi::Runtime &runtime, const jsi::PropNameID &name, const jsi::Value &value) {
  _set(name.utf8(runtime), value);
}

std::vector<jsi::PropNameID> HostObject::getPropertyNames(jsi::Runtime &runtime) {
  std::vector<std::string> propertyNames = _getPropertyNames();
  std::vector<jsi::PropNameID> propertyNamesIds;

  propertyNamesIds.reserve(propertyNames.capacity());

  for (auto &name : propertyNames) {
    propertyNamesIds.push_back(jsi::PropNameID::forUtf8(runtime, name));
  }
  return propertyNamesIds;
}

const jsi::Object HostObject::makeObject(jsi::Runtime &runtime, GetFunction get, SetFunction set, GetPropertyNamesFunction getPropertyNames, DeallocFunction dealloc) {
  auto hostObjectPtr = std::make_shared<HostObject>(get, set, getPropertyNames, dealloc);
  return jsi::Object::createFromHostObject(runtime, hostObjectPtr);
}

} // namespace expo
