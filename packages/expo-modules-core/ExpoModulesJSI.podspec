require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

use_hermes = ENV['USE_HERMES'] == nil || ENV['USE_HERMES'] == '1'

Pod::Spec.new do |s|
  s.name           = 'ExpoModulesJSI'
  s.version        = package['version']
  s.summary        = package['description']
  s.description    = package['description']
  s.license        = package['license']
  s.author         = package['author']
  s.homepage       = package['homepage']
  s.platforms       = {
    :ios => '16.4',
    :osx => '12.0',
    :tvos => '16.4'
  }
  s.swift_version  = '6.0'
  s.source         = { git: 'https://github.com/expo/expo.git' }
  s.static_framework = true
  s.header_dir     = 'ExpoModulesJSI'

  # Swift/Objective-C compatibility
  s.pod_target_xcconfig = {
    'USE_HEADERMAP' => 'YES',
    'DEFINES_MODULE' => 'YES',
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++20',
    'SWIFT_OBJC_INTEROP_MODE' => 'objcxx',
    'OTHER_SWIFT_FLAGS' => '-Xfrontend -clang-header-expose-decls=has-expose-attr',
    'GCC_PREPROCESSOR_DEFINITIONS' => 'EXPO_MODULES_JSI=1'
  }

  if use_hermes
    s.dependency 'hermes-engine'
  else
    s.dependency 'React-jsc'
  end

  s.dependency 'React-Core'
  s.dependency 'ReactCommon'

  s.source_files = ['ios/JSI/**/*.{h,hpp,m,mm,swift,cpp}', 'common/cpp/JSI/**/*.{h,hpp,cpp}']
  s.exclude_files = ['ios/JSI/Tests']
  s.private_header_files = [
    'common/cpp/JSI/*.{h,hpp}',
    'ios/JSI/*.{h,hpp}',
    'ios/JSI/JSwift/*.{h,hpp}',
  ]
  s.public_header_files = [
    'common/cpp/JSI/Public/*.{h,hpp}',
    'ios/JSI/Public/*.{h,hpp}',
  ]

  s.test_spec 'Tests' do |test_spec|
    # Use higher deployment targets than the module itself.
    # It is a bit of a hassle to do availability checks in Swift Testing.
    # Our Swift/C++ interop requires iOS 16.4 as we need macros for reference types.
    test_spec.platforms = {
      :ios => '17.0',
      :osx => '12.0',
      :tvos => '17.0'
    }
    test_spec.source_files = 'ios/JSI/Tests/**/*.{m,swift}'
  end
end
