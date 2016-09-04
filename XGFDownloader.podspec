Pod::Spec.new do |s|
s.name         = "XGFDownloader"
s.version      = "1.0"
s.summary      = "XGFDownloader is used for resume from break point downloading build with swift."
s.homepage     = "https://github.com/Insfgg99x/XGFDownloader"
s.license      = "MIT"
s.authors      = { "CGPointZero" => "newbox0512@yahoo.com" }
s.source       = { :git => "https://github.com/Insfgg99x/XGFDownloader.git", :commit => "4460e93d7c3cb02c147fbd7939f00443b97c258c" }
#s.frameworks   = 'Foundation','UIKit'
s.ios.deployment_target = '8.0'
s.source_files = 'Classes/*.swift'
s.requires_arc = true
#s.dependency 'SDWebImage'
#s.dependency 'pop'
end

