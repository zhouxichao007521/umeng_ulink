#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint umeng_ulink.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'umeng_ulink'
  s.version          = '1.0.0'
  s.summary          = '友盟 U-Link 深度链接 Flutter 插件'
  s.description      = <<-DESC
友盟 U-Link 深度链接 Flutter 插件，支持延迟深度链接、场景还原、邀请归因等功能
                       DESC
  s.homepage         = 'https://github.com/CodeGather/umeng_ulink'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'CodeGather' => 'raohong07@163.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # 友盟 U-Link SDK
  s.dependency 'UMCommon'
  s.dependency 'UMLink'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
