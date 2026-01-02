// Copyright 2025-present 650 Industries. All rights reserved.

#ifdef __cplusplus

#import <string>
#import <vector>
#import <jsi/jsi.h>

namespace jsi = facebook::jsi;

namespace expo {

class JSI_EXPORT HostObject : public jsi::HostObject {
public:
  using GetFunction = jsi::Value(^)(std::string name);
  using SetFunction = void(^)(std::string name, const jsi::Value &value);
  using GetPropertyNamesFunction = std::vector<std::string>(^)();
  using DeallocFunction = void(^)();

  HostObject(GetFunction get, SetFunction set, GetPropertyNamesFunction getPropertyNames, DeallocFunction dealloc);

  virtual ~HostObject();

  jsi::Value get(jsi::Runtime &runtime, const jsi::PropNameID &name) override;

  void set(jsi::Runtime &runtime, const jsi::PropNameID &name, const jsi::Value &value) override;

  std::vector<jsi::PropNameID> getPropertyNames(jsi::Runtime &runtime) override;

  static jsi::Object makeObject(jsi::Runtime &runtime, GetFunction get, SetFunction set, GetPropertyNamesFunction getPropertyNames, DeallocFunction dealloc);

private:
  const GetFunction _get;
  const SetFunction _set;
  const GetPropertyNamesFunction _getPropertyNames;
  const DeallocFunction _dealloc;
}; // class HostObject

} // namespace expo

#endif // __cplusplus
