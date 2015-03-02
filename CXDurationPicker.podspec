#
#  Be sure to run `pod spec lint CXDurationPicker.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "CXDurationPicker"
  s.version      = "0.0.1"
  s.summary      = "Custom UIView which allows user to select a date range from calendar."
  s.license      = "MIT"
  s.authors      = { "Richard Puckett" => "richard.puckett@concur.com" }

  s.ios.deployment_target = "7.0"


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any h, m, mm, c & cpp files. For header
  #  files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  s.source_files  = "CXDurationPicker/*.{h,m}"

  s.ios.frameworks  = "CoreText"

  s.requires_arc = true
end
