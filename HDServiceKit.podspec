Pod::Spec.new do |s|
  s.name             = "HDServiceKit"
  s.version          = "1.6.11"
  s.summary          = "混沌 iOS 服务"
  s.description      = <<-DESC
                       HDServiceKit 是一系列服务以及能力，用于快速在其他项目使用或者第三方接入
                       DESC
  s.homepage         = "https://code.kh-super.net/projects/MOB/repos/hdservicekit"
  s.license          = 'MIT'
  s.author           = {"VanJay" => "wangwanjie1993@gmail.com"}
  s.source           = {:git => "ssh://git@code.kh-super.net:7999/mob/hdservicekit.git", :tag => s.version.to_s}
  s.social_media_url = 'https://code.kh-super.net/projects/MOB/repos/hdservicekit'
  s.requires_arc     = true
  s.documentation_url = 'https://code.kh-super.net/projects/MOB/repos/hdservicekit'

  s.platform         = :ios, '9.0'

  $lib = ENV['use_lib']
  $lib_name = ENV["#{s.name}_use_lib"]
  if $lib || $lib_name
    puts '--------- HDServiceKit binary -------'

    s.frameworks       = 'Foundation', 'UIKit', 'CoreLocation', 'MapKit', 'CoreTelephony', 'AdSupport', 'SafariServices', 'WebKit', 'CoreServices', 'ContactsUI'
    s.ios.vendored_framework = "#{s.name}-#{s.version}/ios/#{s.name}.framework"
    s.resources = "#{s.name}-#{s.version}/ios/#{s.name}.framework/Versions/A/Resources/*.bundle"
    s.dependency  'GCDWebServer', '~> 3.0'
    s.dependency 'AFNetworking', '~>4.0'
    s.dependency 'YYCache', '~>1.0.4'
    s.dependency 'UICKeyChainStore', '~> 2.1.2'
    s.dependency 'YYModel', '~> 1.0.4'
  else
    puts '....... HDServiceKit source ........'

    s.frameworks       = 'Foundation', 'UIKit'
    s.source_files     = 'HDServiceKit/HDServiceKit.h'
    
    s.subspec 'WNHelloWebSocketClient' do |ss|
       ss.source_files = 'HDServiceKit/WNHelloWSClient/**/*'
       ss.dependency 'HDKitCore/Core'
       ss.dependency 'HDKitCore/WNApp'
       ss.dependency 'SocketRocket'
       ss.dependency 'YYModel', '~> 1.0.4'
       ss.dependency 'HDServiceKit/HDDeviceInfo'
       ss.dependency 'HDVendorKit/WNFMDBManager'
       ss.dependency 'HDServiceKit/Location'
    end

    s.subspec 'HDCache' do |ss|
      ss.libraries = 'pthread'
      ss.source_files = 'HDServiceKit/HDCache', 'HDServiceKit/HDCache/*/*'
      ss.dependency 'YYModel', '~> 1.0.4'
      ss.dependency 'UICKeyChainStore', '~> 2.1.2'
    end

    s.subspec 'AntiCrash' do |ss|
      ss.requires_arc = ['HDServiceKit/AntiCrash/NSObjectSafe.h']
      ss.source_files = 'HDServiceKit/AntiCrash'
      ss.dependency 'HDKitCore/MethodSwizzle'
    end

    s.subspec 'Location' do |ss|
      ss.source_files = 'HDServiceKit/Location', 'HDServiceKit/Location/*/*'
      ss.frameworks = 'CoreLocation', 'MapKit'
      ss.ios.resource_bundle = { 'HDLocation' => 'HDServiceKit/Location/GCJ02.json' }
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

    s.subspec 'SystemCapability' do |ss|
      ss.source_files = 'HDServiceKit/SystemCapability'
    end

    s.subspec 'HDDeviceInfo' do |ss|
      ss.source_files = 'HDServiceKit/HDDeviceInfo'
      ss.dependency 'UICKeyChainStore', '~> 2.1.2'
      ss.dependency 'HDServiceKit/HDReachability'
      ss.frameworks = 'CoreTelephony', 'AdSupport'
    end

    s.subspec 'ScanCode' do |ss|
      ss.source_files = 'HDServiceKit/ScanCode'
      ss.dependency  'HDUIKit/MainFrame'
      ss.resource_bundles = {'HDScanCodeResources' => ['HDServiceKit/ScanCode/Resources/*.*']}
    end

    s.subspec 'RSACipher' do |ss|
      ss.source_files = 'HDServiceKit/RSACipher'
    end

    s.subspec 'HDImageCompressTool' do |ss|
      ss.source_files = 'HDServiceKit/HDImageCompressTool'
    end

    s.subspec 'HDNetwork' do |ss|
      ss.source_files = 'HDServiceKit/HDNetwork', 'HDServiceKit/HDNetwork/*/*'
      ss.dependency 'AFNetworking', '~>4.0'
      ss.dependency 'YYCache', '~>1.0.4'
      ss.dependency 'HDKitCore/HDLog'
    end

    s.subspec 'SANetwork' do |ss|
      ss.source_files = 'HDServiceKit/SANetwork'
      ss.dependency 'HDServiceKit/HDNetwork'
      ss.dependency 'HDServiceKit/RSACipher'
      ss.dependency 'HDServiceKit/HDDeviceInfo'
      ss.dependency 'HDKitCore/Core'
    end

    s.subspec 'HDWebViewHost' do |ss|
      ss.dependency 'HDServiceKit/FileOperation'

      ss.subspec 'Core' do |ss|
        ss.libraries = 'xml2', 'z'
        ss.frameworks = 'SafariServices', 'WebKit', 'MobileCoreServices', 'ContactsUI' , 'Photos'
        ss.xcconfig = { "HEADER_SEARCH_PATHS" => ["$(SDKROOT)/usr/include/libxml2", "$(SDKROOT)/usr/include/libz"] }
        ss.source_files = 'HDServiceKit/HDWebViewHost/Core', 'HDServiceKit/HDWebViewHost/Core/*/*.{h,m}'
        ss.resource_bundles = {'HDWebViewHostCoreResources' => ['HDServiceKit/HDWebViewHost/Core/Resources/*.*']}
        ss.dependency  'HDUIKit/MainFrame'
        ss.dependency  'HDServiceKit/HDReachability'
        ss.dependency  'HDUIKit/Components/HDTips'
        ss.dependency  'HDServiceKit/SystemCapability'
        ss.dependency  'HDServiceKit/HDDeviceInfo'
        ss.dependency  'HDServiceKit/Location'
        ss.dependency  'HDServiceKit/ScanCode'
        ss.dependency  'HDVendorKit/HDWebImageManager'
        ss.dependency  'HDUIKit/Components/NAT'
        ss.dependency  'HDUIKit/Components/UIViewPlaceholder'
        ss.dependency  'Masonry'
        ss.dependency  'HDKitCore/Core'
      end

      ss.subspec 'RemoteDebug' do |ss|
        ss.source_files = 'HDServiceKit/HDWebViewHost/RemoteDebug'
        ss.resource_bundles = {'HDWebViewHostRemoteDebugResources' => ['HDServiceKit/HDWebViewHost/RemoteDebug/src/*']}
        ss.dependency  'HDServiceKit/HDWebViewHost/Core'
        ss.dependency  'GCDWebServer', '~> 3.0'
      end

      ss.subspec 'Preloader' do |ss|
        ss.source_files = 'HDServiceKit/HDWebViewHost/Preloader/*/*'
        ss.resource_bundles = {'HDWebViewHostPreloaderResources' => ['HDServiceKit/HDWebViewHost/Preloader/html/*.*']}
        ss.dependency  'HDServiceKit/HDWebViewHost/Core'
      end

    end
  end

end
