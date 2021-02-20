Pod::Spec.new do |s|
  s.name             = 'WeChatQRScan'
  s.version          = '0.1.0'
  s.summary          = 'A short description of WeChatQRScan.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Dx-zuo/WeChatQRScan'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Dx-zuo' => 'rickzuo@tencent.com' }
  s.source           = { :git => 'https://github.com/Dx-zuo/WeChatQRScan.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.static_framework = true

  s.source_files = 'WeChatQRScan/Classes/**/*'
  s.vendored_frameworks = 'WeChatQRScan/Framework/opencv2.framework'

  s.resource_bundles = {
    'opencv_3rdparty' => ['WeChatQRScan/Assets/*']
  }
  
  s.module_name = 'WeChatQRScan'
  s.header_dir = 'WeChatQRScan'
  s.libraries = [
   'c++'
  ]
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES'
  }
#  s.compiler_flags = [
#      '-fno-omit-frame-pointer',
#      '-fexceptions',
#      '-Wall',
#      '-Werror',
#      '-std=c++1y',
#      '-fPIC'
#  ]
end
