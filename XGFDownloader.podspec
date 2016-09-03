Pod::Spec.new do |s|
s.name         = "XGFDownloader"
s.version      = "1.0"
s.summary      = "XGFDownloader is used for resume from break point downloading build with swift."
s.homepage     = "https://github.com/Insfgg99x/XGFDownloader"
s.license      = "MIT"
s.authors      = { "CGPointZero" => "newbox0512@yahoo.com" }
s.source       = { :git => "https://github.com/Insfgg99x/XGFDownloader.git", :tag => "1.0" }
#s.frameworks   = 'Foundation','UIKit'
s.ios.deployment_target = '7.0'
s.osx.deployment_target = '10.5'
s.tvos.deployment_target = '9.0'
s.source_files = 'XGFDonwloader_swift/*.swfit'
s.requires_arc = true
#s.dependency 'SDWebImage'
#s.dependency 'pop'
end

