
Pod::Spec.new do |s|
  s.name             = 'BLIAPManager'
  s.version          = '1.0.1'
  s.summary          = 'BLIAPManager'


  s.description      = <<-DESC
    BLIAPManager内购管理工具
                       DESC

  s.homepage         = 'https://github.com/boundlessocean/BLIAPManager'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'boundlessocean@icloud.com' => 'boundlessoean@icloud.com' }
  s.source           = { :git => 'https://github.com/boundlessocean/BLIAPManager.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'BLIAPManager/Classes/**/*'
  s.frameworks = 'StoreKit'
end
