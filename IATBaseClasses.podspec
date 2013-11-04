#
#  Be sure to run `pod spec lint IATBaseClasses.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "IATBaseClasses"
  s.version      = "0.0.1"
  s.summary      = "Ingenious Arts and Technologies - Objects for building iOS apps.  Of particular interest is probably the classes for building 3D Cover-Flow-Like Carousels."
  s.homepage     = "http://github.com/karnlund/IATBaseClasses"
  s.license      =   { :type => 'MIT', :file => 'License.rtf' }
  s.author       = { "Kurt Arnlund" => "kurt@iatapps.com" }
  s.platform     = :ios, '5.0'
  s.requires_arc = true
  s.source       = { :git => "https://github.com/karnlund/IATBaseClasses.git", :tag => "0.0.1" }
  s.source_files  = 'IATBaseClasses', 'IATBaseClasses/**/*.{h,m}'
  s.exclude_files = 'IATCarouselTest/*', 'IATBaseClassesTests/*'
  s.public_header_files = 'IATBaseClasses/*.h'
  s.ios.frameworks  = 'UIKit', 'QuartzCore', 'Foundation'

end
