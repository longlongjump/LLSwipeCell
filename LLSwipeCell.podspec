Pod::Spec.new do |s|
  s.name         = "LLSwipeCell"
  s.summary      = "LLSwipeCell"
  s.version      = "0.2"
  s.homepage     = "https://github.com/longlongjump/LLSwipeCell"
  s.license      = "MIT"
  s.author       = { "Eugene Ovchynnykov" => "eugene.ovchynnykov@gmail.com" }
  s.source       = { :git => "https://github.com/longlongjump/LLSwipeCell.git", :tag => s.version.to_s }
  s.platform     = :ios
  s.ios.deployment_target = '8.0'
  s.requires_arc = true
  s.source_files  = "LLSwipeCell/*"
end
