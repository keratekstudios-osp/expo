// Copyright 2024-present 650 Industries. All rights reserved.

#import <ExpoModulesCore/EXHostWrapper.h>

#import <ReactCommon/RCTHost.h>
#import <React/RCTSurfacePresenter.h>
#import <React/RCTMountingManager.h>
#import <React/RCTComponentViewRegistry.h>

@implementation EXHostWrapper {
  __weak RCTHost *_host;
}

- (instancetype)initWithHost:(RCTHost *)host
{
  if (self = [super init]) {
    _host = host;
  }
  return self;
}

- (nullable UIView *)findViewWithTag:(NSInteger)tag
{
  RCTComponentViewRegistry *componentViewRegistry = _host.surfacePresenter.mountingManager.componentViewRegistry;
  return [componentViewRegistry findComponentViewWithTag:tag];
}

@end

@implementation EXRuntimeWrapper {
  facebook::jsi::Runtime *_runtime;
}

- (instancetype)initWithRuntime:(facebook::jsi::Runtime &)runtime
{
  if (self = [super init]) {
    _runtime = &runtime;
  }
  return self;
}

- (facebook::jsi::Runtime &)pull
{
  facebook::jsi::Runtime &runtime = *_runtime;
  _runtime = nullptr;
  return runtime;
}

@end
