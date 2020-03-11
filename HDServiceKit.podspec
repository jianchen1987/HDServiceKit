Pod::Spec.new do |s|
  s.name             = "HDServiceKit"
  s.version          = "0.4.1"
  s.summary          = "混沌 iOS 服务"
  s.description      = <<-DESC
                       HDServiceKit 是一系列服务以及能力，用于快速在其他项目使用或者第三方接入
                       DESC
  s.homepage         = "https://git.vipaylife.com/vipay/HDServiceKit"
  s.license          = 'MIT'
  s.author           = {"VanJay" => "wangwanjie1993@gmail.com"}
  s.source           = {:git => "git@git.vipaylife.com:vipay/HDServiceKit.git", :tag => s.version.to_s}
  s.social_media_url = 'https://git.vipaylife.com/vipay/HDServiceKit'
  s.requires_arc     = true
  s.documentation_url = 'https://git.vipaylife.com/vipay/HDServiceKit'
  s.screenshot       = 'https://xxx.png'

  s.platform         = :ios, '9.0'
  s.frameworks       = 'Foundation', 'UIKit'
  s.source_files     = 'HDServiceKit/HDServiceKit.h'

  s.subspec 'HDCache' do |ss|
    ss.libraries = 'pthread'
    ss.source_files = 'HDServiceKit/HDCache', 'HDServiceKit/HDCache/*/*'
    ss.dependency 'YYModel', '~> 1.0.4'
    ss.dependency 'UICKeyChainStore', '~> 2.1.2'
  end

  s.subspec 'AntiCrash' do |ss|
    ss.requires_arc = ['HDServiceKit/AntiCrash/NSObjectSafe.h']
    ss.source_files = 'HDServiceKit/AntiCrash'
    ss.dependency 'HDUIKit/MethodSwizzle'
  end

  s.subspec 'Location' do |ss|
    ss.source_files = 'HDServiceKit/Location', 'HDServiceKit/Location/*/*'
    ss.frameworks = 'CoreLocation', 'MapKit'
    ss.dependency  'HDUIKit/HDLog'
  end

  s.subspec 'FileOperation' do |ss|
    ss.source_files = 'HDServiceKit/FileOperation'
  end

  s.subspec 'HDReachability' do |ss|
    ss.source_files = 'HDServiceKit/HDReachability'
  end

  s.subspec 'HDPodAsset' do |ss|
    ss.source_files = 'HDServiceKit/HDPodAsset'
  end

  s.subspec 'HDWebViewHost' do |ss|
    ss.dependency 'HDServiceKit/FileOperation'

    ss.subspec 'Core' do |ss|
      ss.libraries = 'xml2', 'z'
      ss.frameworks = 'SafariServices', 'WebKit', 'MobileCoreServices'
      ss.xcconfig = { "HEADER_SEARCH_PATHS" => ["$(SDKROOT)/usr/include/libxml2", "$(SDKROOT)/usr/include/libz"] }
      ss.source_files = 'HDServiceKit/HDWebViewHost/Core', 'HDServiceKit/HDWebViewHost/Core/**/*.{h,m}'
      ss.resource_bundles = {'HDWebViewHostCoreResources' => ['HDServiceKit/HDWebViewHost/Core/Resources/*.*']}
      ss.dependency  'HDUIKit/MainFrame'
      ss.dependency  'HDServiceKit/HDReachability'
      ss.dependency 'HDUIKit/Components/HDTips'
    end

    ss.subspec 'RemoteDebug' do |ss|
      ss.source_files = 'HDServiceKit/HDWebViewHost/RemoteDebug', 'HDServiceKit/HDWebViewHost/RemoteDebug/GCDWebServer/**/*'
      ss.resource_bundles = {'HDWebViewHostRemoteDebugResources' => ['HDServiceKit/HDWebViewHost/RemoteDebug/src/*']}
      ss.dependency  'HDServiceKit/HDWebViewHost/Core'
      ss.dependency  'HDServiceKit/HDPodAsset'
    end

    ss.subspec 'Preloader' do |ss|
      ss.source_files = 'HDServiceKit/HDWebViewHost/Preloader/*/*'
      ss.resource_bundles = {'HDWebViewHostPreloaderResources' => ['HDServiceKit/HDWebViewHost/Preloader/html/*.*']}
      ss.dependency  'HDServiceKit/HDWebViewHost/Core'
    end

  end

end
