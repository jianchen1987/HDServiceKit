Pod::Spec.new do |s|
  s.name             = "HDServiceKit"
  s.version          = "0.1.0"
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
    ss.source_files = 'HDServiceKit/HDCache', 'HDServiceKit/HDCache/*/*'
    ss.dependency 'YYModel', '~> 1.0.4'
    ss.dependency 'UICKeyChainStore', '~> 2.1.2'
  end

end
