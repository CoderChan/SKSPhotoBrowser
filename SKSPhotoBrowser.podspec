#
#  Be sure to run `pod spec lint SKSPhotoBrowser.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "SKSPhotoBrowser"

  spec.version      = "1.0.1"

  spec.summary      = "一行代码实现从相册中选择图片并裁剪，适用于选择头像场景，ease to use..."

  spec.homepage     = "https://github.com/CoderChan/SKSPhotoBrowser"

  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author       = { "陈振超" => "czc1943@126.com" }

  spec.platform     = :ios, "9.0"

  spec.ios.deployment_target = "9.0"

  spec.requires_arc = true

  spec.source       = { :git => "https://github.com/CoderChan/SKSPhotoBrowser.git", :tag => spec.version }

  spec.source_files  = "SKSPhotoBrowser", "SKSPhotoBrowser/**/*.{h,m}"

  spec.resources     = 'SKSPhotoBrowser/**/*.{png,bundle}'

  # spec.exclude_files = "Classes/Exclude"

  spec.frameworks = "UIKit", "Foundation", "QuartzCore", "Photos"

  spec.dependency "Masonry"

end
