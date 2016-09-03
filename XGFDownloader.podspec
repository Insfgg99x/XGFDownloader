Pod::Spec.new do |s|
s.name         = "XGFDownloader"
s.version      = "1.0"
s.summary      = "XGFDownloader is used for resume from break point downloading build with swift."
s.homepage     = "https://github.com/Insfgg99x/XGFDownloader"
s.license      = "MIT"
s.authors      = { "CGPointZero" => "newbox0512@yahoo.com" }
s.source       = { :git => "https://github.com/Insfgg99x/XGFDownloader.git", :tag => "1.0" }
s.frameworks   = 'Foundation','UIKit'
s.platform     = :ios, '7.0'
s.source_files = 'XGFDownloader/*.{swfit}'
s.requires_arc = true
#s.dependency 'SDWebImage'
#s.dependency 'pop'
end

