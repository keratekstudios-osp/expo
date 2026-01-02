// Copyright 2025-present 650 Industries. All rights reserved.

#ifdef __cplusplus

#import <string>
#import <vector>
#import <jsi/jsi.h>

namespace jsi = facebook::jsi;

namespace expo {

class HostObject : public jsi::HostObject {
public:
  using GetFunction = jsi::Value(^)(std::string name);
  using SetFunction = void(^)(std::string name, const jsi::Value &value);
  using GetPropertyNamesFunction = std::vector<std::string>(^)();
  using DeallocFunction = void(^)();

  HostObject(GetFunction get, SetFunction set, GetPropertyNamesFunction getPropertyNames, DeallocFunction dealloc);

  virtual ~HostObject();

  jsi::Value get(jsi::Runtime &, const jsi::PropNameID &name) override;

  void set(jsi::Runtime &, const jsi::PropNameID &name, const jsi::Value &value) override;

  std::vector<jsi::PropNameID> getPropertyNames(jsi::Runtime &rt) override;

  static const jsi::Object makeObject(jsi::Runtime &runtime, GetFunction get, SetFunction set, GetPropertyNamesFunction getPropertyNames, DeallocFunction dealloc);

private:
  GetFunction _get;
  SetFunction _set;
  GetPropertyNamesFunction _getPropertyNames;
  DeallocFunction _dealloc;
}; // class HostObject

} // namespace expo

#endif // __cplusplus
