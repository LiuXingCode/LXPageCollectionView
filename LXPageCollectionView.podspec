
Pod::Spec.new do |s|

  s.name         = "LXPageCollectionView"
  s.version      = "1.0"
  s.summary      = "A frame similar to a WeChat expression keyboard"
  s.homepage     = "https://github.com/LiuXingCode/LXPageCollectionView"
  s.license      = "MIT"
  s.author       = { "xing.liu" => "liuxinghenau@163.com" }
  s.source       = { :git => "https://github.com/LiuXingCode/LXPageCollectionView.git", :tag => "#{s.version}" }
  s.source_files  = "LXPageCollectionViewLib/**/*.swift"
  s.ios.deployment_target = '8.0'

end
